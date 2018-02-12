" autoload/surfer.vim


" Helper functions
" -----------------------------------------------------------------------------

fu! s:Pyeval(expr)
    if exists("*pyeval")
        return pyeval(a:expr)
    endif
    py vim.command("let result = {0}".format(repr(vim.eval("a:expr"))))
    return result
endfu

fu! s:Echo(msg, ...)
    if a:0 > 0
        exec "echohl " . a:1
    endif
    echom "[surfer] " . a:msg
    echohl None
endfu

fu! s:InstallSearchComponent()
    call s:Echo("Installing the search component...")
    sleep 1500m
    if s:CompileSearchComponent()
        call s:Echo("The search component has been successfully installed!")
    else
        call s:Echo("An error occurred while installing the search component!", "WarningMsg")
    endif
    sleep 2
endfu

fu! s:UpdateSearchComponent()
    call s:Echo("Updating the search component...")
    sleep 1500m
    if s:CompileSearchComponent()
        call s:Echo("The search component has been successfully updated!")
    else
        call s:Echo("An error occurred while updating the search component!", "WarningMsg")
    endif
    sleep 2
endfu

fu! s:CompileSearchComponent()
    let out = system(s:extension_folder . "/install.sh")
    return !v:shell_error
endfu


" Deferred initialization
" -----------------------------------------------------------------------------

let s:plugin_folder = fnamemodify(globpath(&rtp, "plugin/surfer.vim"), ":h")
let s:extension_folder = s:plugin_folder . "/surfer/search/ext"
let s:extension_version = 3
" `s:extension_version` MUST match the `version` constant in the extension module
" surfer.search.ext.search so that we know when to recompile it.

if !has("win32")
    if !filereadable(s:extension_folder . "/search.so")
        call s:InstallSearchComponent()
    else
        py import surfer.search.ext.search
        if s:extension_version > s:Pyeval("getattr(surfer.search.ext.search, '__version__', -1)")
            call s:UpdateSearchComponent()
        endif
    endif
endif


" Wrappers
" ----------------------------------------------------------------------------

fu! surfer#Open()
    py _surfer.open()
endfu
