" plugin/surfer_settings.vim

" Helpers
" -----------------------------------------------------------------------------

" To automatically spot where Exuberant Ctags is located
fu! s:FindCtagsProgram(prg)
    if filereadable(a:prg)
        return a:prg
    endif
    if has("win32")
        " `globpath()` needs forward slashes even on Windows
        let PATH = join(split(substitute($PATH, '\', '/', 'g'), ";"), ",")
    else
        let PATH = join(extend(split($PATH, ":"), ["/usr/local/bin", "/usr/bin"]), ",")
    endif
    for candidate in ['ctags', 'ctags-exuberant', 'exctags', 'ctags.exe']
        for ctags in split(globpath(PATH, candidate), "\n")
            let out = system(ctags . " --version")
            if v:shell_error == 0 && match(out, "Exuberant Ctags") != -1
                return ctags
            endif
        endfor
    endfor
    return a:prg
endfu


" Initialize settings
" ----------------------------------------------------------------------------

let g:surfer_debug = get(g:, "surfer_debug", 0)

" Core options

let g:surfer_ctags_prg =
    \ s:FindCtagsProgram(get(g:, "surfer_ctags_prg", ""))

let g:surfer_ctags_args =
    \ get(g:, "surfer_ctags_args",
    \ " --excmd=number --format=2 --sort=yes  --fields=nKzmafilmsSt ")

let g:surfer_generate_tags =
    \ get(g:, "surfer_generate_tags", 1)

let g:surfer_smart_case =
    \ get(g:, "surfer_smart_case", 1)

let g:surfer_root_markers =
    \ extend(get(g:, 'surfer_root_markers', []),
    \ ['.git', '.svn', '.hg', '.bzr'])

let g:surfer_exclude_tags =
    \ get(g:, "surfer_exclude_tags", [])

let g:surfer_exclude_kinds =
    \ get(g:, "surfer_exclude_kinds", [])

let g:surfer_filters =
    \ extend({"#": "SurferProjectFilter", "%": "SurferBufferFilter",  " ": "SurferSessionFilter"},
    \ get(g:, "surfer_filters", {}), "force")

" Appearance

let g:surfer_max_results =
    \ get(g:, "surfer_max_results", 15)

let g:surfer_cursorline =
    \ get(g:, "surfer_cursorline", 1)

let g:surfer_no_results_msg =
    \ get(g:, "surfer_no_results_msg", " nothing found...")

let g:surfer_prompt =
    \ extend({"appearance" : "@ ", "color" : "", "color_darkbg": ""},
    \ get(g:, "surfer_prompt", {}), "force")

let g:surfer_curr_line_indicator =
    \ extend({"appearance" : " ", "color" : "", "color_darkbg": ""},
    \ get(g:, "surfer_curr_line_indicator", {}), "force")

let g:surfer_line_format =
    \ get(g:, "surfer_line_format", [" @ {file}"])

let g:surfer_tag_file_custom_depth =
    \ get(g:, "surfer_tag_file_custom_depth", -1)

let g:surfer_tag_file_relative_to_project_root =
    \ get(g:, "surfer_tag_file_relative_to_project_root", 1)

let g:surfer_shade =
    \ extend({"color" : "Comment", "color_darkbg": ""},
    \ get(g:, "surfer_shade", {}), "force")

let g:surfer_matches =
    \ extend({"color" : "WarningMsg", "color_darkbg": ""},
    \ get(g:, "surfer_matches", {}), "force")

let g:surfer_visual_kinds =
    \ extend({"active" : 1, "appearance" : "\u2022 "},
    \ get(g:, "surfer_visual_kinds", {}), "force")

let g:surfer_visual_kinds["colors"] =
    \ extend(get(g:surfer_visual_kinds, "colors", {}), {
        \ "interface": "Repeat", "class": "Repeat",
        \ "member": "Function", "method": "Function", "function": "Function",
        \ "type": "Type", "struct": "Type",
        \ "variable": "Conditional", "constant": "Conditional", "macro": "Conditional",
        \ "field": "String", "property": "String",
        \ "namespace": "Constant", "package": "Constant",
    \ },
    \ "keep")

let g:surfer_visual_kinds["colors_darkbg"] = g:surfer_visual_kinds.colors
