" ============================================================================
" File: plugin/surfer.vim
" Description: Code navigator for vim
" Mantainer: Giacomo Comitti (https://github.com/gcmt)
" Url: https://github.com/gcmt/vim-surfer
" License: MIT
" ============================================================================


if exists("g:surfer_loaded")
    finish
endif

fu! s:EchoErr(msg)
    echohl WarningMsg | echom "Surfer unavailable: " . a:msg | echohl None
endfu

if v:version < 703
    command! Surf call s:EchoErr("requires Vim 7.3+")
    finish
endif

if !has('python')
    command! Surf call s:EchoErr("requires Python 2.x (2.6+)")
    finish
endif

python << END
import sys
major, minor = sys.version_info[:2]
if major != 2 and minor not in (6, 7):
    vim.command("let s:unsupported_python = 1")
END
if exists("s:unsupported_python")
    command! Surf call s:EchoErr("requires Python 2.x (2.6+)")
    finish
endif

" Init
" ----------------------------------------------------------------------------

let g:surfer_loaded = 1
let g:surfer_version = "3.0"
let s:current_folder = expand("<sfile>:p:h")

py import vim, sys
py sys.path.insert(0, vim.eval("s:current_folder"))

exe "so " . s:current_folder . "/surfer_settings.vim"

python << END
import types, surfer.utils.filters
# keep track of user-defined functions because later we can't access them
for name, obj in globals().items():
    if isinstance(obj, types.FunctionType):
        surfer.utils.filters.user_functions[name] = obj
END

py import surfer.core
py _surfer = surfer.core.Surfer()


" Commands
" ----------------------------------------------------------------------------

command! Surf call surfer#Open()


" Autocommands
" ----------------------------------------------------------------------------

py import surfer.utils.misc, surfer.utils.v, Queue

fu! s:CheckTagfilesForChanges()
    if empty(&buftype)
        py _surfer.loader.watcher.tagfiles.put_nowait(surfer.utils.v.tagfiles())
    endif
endfu

let s:events_count = 0
fu! s:CheckTagfilesForChanges_Lazy(interval)
    if s:events_count % a:interval == 0 | call s:CheckTagfilesForChanges() | endif
    let s:events_count += 1
endfu

fu! s:RebuildTags()
    py _surfer.generator.rebuild.put_nowait((
        \ surfer.utils.misc.find_root(surfer.utils.v.cwd()),
        \ surfer.utils.v.buffers()))
endfu

let s:last_project_root = ""
fu! s:RebuildTagsIfProjectChanged()
python << END
project_root = surfer.utils.misc.find_root(surfer.utils.v.cwd())
if project_root != vim.eval("s:last_project_root"):
    vim.eval("s:RebuildTags()")
    vim .command("let s:last_project_root = '{0}'".format(project_root))
END
endfu

fu! s:GetGeneratedTagfiles()
python << END
try:
    surfer.utils.v.set_tagfiles(_surfer.generator.tagfiles.get_nowait())
    vim.eval("s:CheckTagfilesForChanges()")
except Queue.Empty:
    pass
END
endfu

augroup surfer
    au!

    au BufWritePost .vimrc py _surfer.ui.setup_colors()
    au Colorscheme * py _surfer.ui.setup_colors()
    au VimLeave * py _surfer.close()

    " surfer.watcher.TagfilesWatcher stuff
    au CursorHold,CursorHoldI,BufEnter,Filetype,FocusGained * call s:CheckTagfilesForChanges()
    au CursorMoved,CursorMovedI * call s:CheckTagfilesForChanges_Lazy(10)

    " surfer.generator.Generator stuff
    if g:surfer_generate_tags
        au VimEnter,BufWritePost * call s:RebuildTags()
        au BufEnter * call s:RebuildTagsIfProjectChanged()
        au CursorMoved,CursorMovedI,CursorHold,CursorHoldI,BufEnter,Filetype,FocusGained * call s:GetGeneratedTagfiles()
    endif

augroup END
