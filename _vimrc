"
" TODO: try to make Vim portable.
" Note that the following items are saved by Vim while it is working: 
"    *) undofiles
"    *) swp
"    *) netrw
"    ??*) undofiles (maybe remove it at all from my vimrc, anyway I never used it)
"
":redir >> D:/vimlog.txt
" определяем путь к папке с этим файлом _vimrc
let s:sPath = expand('<sfile>:p:h')

" copied from $VIMRUNTIME/vimrc_example.vim, and adjusted a bit {{{

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
   set nobackup		" do not keep a backup file, use versions instead
else
   set backup		" keep a backup file (restore to previous version)
   set undofile		" keep an undo file (undo changes after closing)
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
   set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
   syntax on
   set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

   " Enable file type detection.
   " Use the default filetype settings, so that mail gets 'tw' set to 72,
   " 'cindent' is on in C files, etc.
   " Also load indent files, to automatically do language-dependent indenting.
   filetype plugin indent on

   " Put these in an autocmd group, so that we can delete them easily.
   augroup vimrcEx
      au!

      " For all text files set 'textwidth' to 78 characters.
      autocmd FileType text setlocal textwidth=78

      " When editing a file, always jump to the last known cursor position.
      " Don't do it when the position is invalid or when inside an event handler
      " (happens when dropping a file on gvim).
      "
      " COMMENTED by dfrank, since we have this functionality below, but
      " adjusted for git commit message editing
      "
      "autocmd BufReadPost *
               "\ if line("'\"") >= 1 && line("'\"") <= line("$") |
               "\   exe "normal! g`\"" |
               "\ endif

   augroup END

else

   set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
   command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
            \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
   " Prevent that the langmap option applies to characters that result from a
   " mapping.  If unset (default), this may break plugins (but it's backward
   " compatible).
   set langnoremap
endif

" }}}

let s:sWinposScript = s:sPath.'/_vimrc_winpos'
if filereadable(s:sWinposScript)
   exec 'source '.s:sWinposScript
endif
unlet s:sWinposScript

let s:sWinposScript = s:sPath.'/machine_local_conf/current/winpos.vim'
if filereadable(s:sWinposScript)
   exec 'source '.s:sWinposScript
endif
unlet s:sWinposScript

" цветовая схема
"exec 'source '.s:sPath.'/colors/darkblue_my.vim'
"exec 'source '.s:sPath.'/colors/desert256_my.vim'
"exec 'source '.s:sPath.'/colors/automation.vim'

"source $VIMRUNTIME/colors/darkblue.vim
"source $VIMRUNTIME/colors/desert.vim
"source $VIMRUNTIME/colors/peachpuff.vim
"source $VIMRUNTIME/colors/github.vim

exec 'source '.s:sPath.'/colors/lucius.vim'
:LuciusLightHighContrast

"let loaded_matchparen = 1
"let s:sVimrcSmall = s:sPath."/_vimrc_small"

"exec 'source '.s:sVimrcSmall

exec 'source '.s:sPath.'/machine_local_conf/current/variables.vim'


set fencs=utf8,cp1251    " порядок перебора кодировок при открытии файла
                         "set encoding=utf-8
set ffs=dos,unix         " порядок перебора fileformats
set nocompatible         " несовместим с Vi
set nowrap               " не переносим слова
set nu                   " нумерация строк
set ic                   " поиск без учета регистра
set expandtab            " юзаем пробелы вместо символов таб
set hidden               " не выгружать буфер при переходе на другой файл
                         "set cscopetag         " по Ctrl+] вести себя так же, как по g] (показывать варианты)
set updatetime=1000      " время обновления - 1 сек
set scrolloff=5          " чтобы курсор не прилипал к краям экрана
set guioptions-=T        " прячем toolbar в gui
set guioptions-=m        " прячем menu в gui
set history=4000         " история команд, строк поиска, итд
set laststatus=2         " показывать statusline всегда. 
                         " (по умолчанию laststatus=1 , тогда строки статуса нету, если открыто только одно окно.)
set linebreak            " в режиме wrap переносим целиком слова, вместо того чтобы разрывать слово посередине
set vb                   " visual-bell
set virtualedit=block    " :h virtualedit for information =)
set fileformats=unix,dos " default fileformat should be "unix"
set foldmethod=marker

set re=1

" there is a way to get current fold name suggested by osse. Maybe I will
" use it in the future.
"
" echo substitute(getline(search('{'.'{{$', 'nb')), '// \(.*\) {'.'{{$', '\1', '')

"set cursorline        " Подсвечиваем текущую строку

" set autoformat params for *.txt files:
" "tcq" is default, "a" is for auto-apply &textwidth (now it is removed) , "n"
" is for automatically recognize numbered list (well, not only numbered. look
" my next option)
au BufReadPost *\.txt let &l:fo = 'tcqn'

" make Vim recognize not only numbered lists, but also lists with items like
" *)
au BufReadPost *\.txt let &l:formatlistpat = '\v^\s*(\d+|\*)[\]:.)}\t ]\s*'


" restore last position for each opened file
function! s:PositionCursorFromViminfo()
   if !(bufname("%") =~ '\(COMMIT_EDITMSG\)')
            \ && line("'\"") > 1 && line("'\"") <= line("$")
      exe "normal! g`\""
   endif
endfunction
:au BufReadPost * call s:PositionCursorFromViminfo()

" when yank, let cursor stay where it was when 'y' has been pressed.
" vnoremap y mty`t
vnoremap y ygv<Esc>
vnoremap = =gv<Esc>
vnoremap > >gv<Esc>
vnoremap < <gv<Esc>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" command-line distraction free up and down
cnoremap <C-K> <Up>
cnoremap <C-J> <Down>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" command-line emacs-like keybindings
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>

cnoremap <C-t> <C-f>

" без следующего заклинания регистронезависимый поиск по кириллице в Windows
" работает криво.
" TODO: проверять не has('winXX'), а кодировку Vim, или как-то так.
" Надо потестировать, от чего это зависит.
if (has('win32') || has('win64'))
   language ctype Russian_Russia.1251
endif

" уговариваем таки Vim прыгать по русским словам в кодировке cp1251
set iskeyword=@,48-57,_,192-255

" create swp files in the specified dir
let s:sMySwpDir = $HOME.'/.vim/swp'
if (!isdirectory(s:sMySwpDir))
   call mkdir(s:sMySwpDir, "p")
endif
exec 'set dir='.substitute(s:sMySwpDir, '\([ \\]\)', '\\\1', 'g').''

" create netrwhist files in the specified dir
let s:sMyNetrwDir = $HOME.'/.vim/netrw'
if (!isdirectory(s:sMyNetrwDir))
   call mkdir(s:sMyNetrwDir, "p")
endif
exec 'let g:netrw_home="'.substitute(s:sMyNetrwDir, '\([ \\]\)', '\\\1', 'g').'"'


" russian keymap
"set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯЖ;ABCDEFGHIJKLMNOPQRSTUVWXYZ:,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
"set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\;'zxcvbnm\,.~QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>
"set langmap=ёйцукенгшщзхъфывапролджэячсмитьбю;`qwertyuiop[]asdfghjkl\;'zxcvbnm\,.,ЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>/

set langmap=йq,цw,уe,кr,еt,нy,гu,шi,щo,зp,х[,ъ],фa,ыs,вd,аf,пg,рh,оj,лk,дl,ж\\;,э',яz,чx,сc,мv,иb,тn,ьm,б\\,,ё`,ЙQ,ЦW,УE,КR,ЕT,НY,ГU,ШI,ЩO,ЗP,Х{,Ъ},ФA,ЫS,ВD,АF,ПG,РH,ОJ,ЛK,ДL,Э\",ЯZ,ЧX,СC,МV,ИB,ТN,ЬM,Б\<,Ю\>,Ё\~,Ж:

set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
highlight lCursor guifg=NONE guibg=Cyan
"setlocal spell spelllang=ru_yo,en_us

" map <F1> to return to the normal mode
nnoremap <F1> <Esc>
vnoremap <F1> <Esc>
inoremap <F1> <Esc>

" супер-ремапинги crib, clib, etc
noremap <Leader>crib vibo``c
noremap <Leader>clib vib``c
noremap <Leader>criB viBo``c
noremap <Leader>cliB viB``c
noremap <Leader>crab vabo``c
noremap <Leader>clab vab``c
noremap <Leader>craB vaBo``c
noremap <Leader>claB vaB``c

noremap <Leader>vrib vibo``
noremap <Leader>vlib vib``
noremap <Leader>vriB viBo``
noremap <Leader>vliB viB``
noremap <Leader>vrab vabo``
noremap <Leader>vlab vab``
noremap <Leader>vraB vaBo``
noremap <Leader>vlaB vaB``

noremap <Leader>drib vibo``x
noremap <Leader>dlib vib``x
noremap <Leader>driB viBo``x
noremap <Leader>dliB viB``x
noremap <Leader>drab vabo``x
noremap <Leader>dlab vab``x
noremap <Leader>draB vaBo``x
noremap <Leader>dlaB vaB``x

" настраиваем Vim на удобную работу в режиме wrap
"
" проблемы вроде бы только с home-end в визуальном режиме:
" если ремапить их как g^ , g$ , то 

nnoremap <silent> k gk
nnoremap <silent> j gj
nnoremap <silent> ^      :SmartHomeKey<CR>
nnoremap <silent> $      :SmartEndKey<CR>

nnoremap <silent> <Up> g<Up>
nnoremap <silent> <Down> g<Down>
nnoremap <silent> <Home> :SmartHomeKey<CR>
nnoremap <silent> <End>  :SmartEndKey<CR>

"nnoremap <silent> I  g^i
"nnoremap <silent> A  g$a

vnoremap <silent> k gk
vnoremap <silent> j gj
"vnoremap <silent> ^ <C-R>=&wrap ? "g^" : "^"
"vnoremap <silent> $ <C-R>=&wrap ? "g$" : "$"
"vnoremap <silent> ^ g^
"vnoremap <silent> $ g$

vnoremap <silent> <Up> g<Up>
vnoremap <silent> <Down> g<Down>
"vnoremap <silent> <Home> <C-R>=&wrap ? "g\<lt>Home>" : "\<lt>Home>"
"vnoremap <silent> <End> <C-R>=&wrap ? "g\<lt>End>" : "\<lt>End>"
"vnoremap <silent> <Home> g<Home>
"vnoremap <silent> <End> g<End>

inoremap <silent> <Up> <C-R>=pumvisible() ? "\<lt>Up>" : "\<lt>C-O>g\<lt>Up>"<CR>
inoremap <silent> <Down> <C-R>=pumvisible() ? "\<lt>Down>" : "\<lt>C-O>g\<lt>Down>"<CR>
inoremap <silent> <Home> <C-O>:SmartHomeKey<CR>
inoremap <silent> <End> <C-O>:SmartEndKey<CR>


" Windows Compatible {
" On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
" across (heterogeneous) systems easier.
if has('win32') || has('win64')
   set runtimepath+=$HOME/.vim
endif
" }

" мапим <Leader>= на выравнивание блока текста от текущей строки до matching строки
"map <Leader>=     mt=%`t
map <Leader>=     =%%


" -------------------------- pathogen ----------------------------
let g:pathogen_disabled=[]

if !empty($VIM_LIGHT_MODE)
   call add(g:pathogen_disabled, 'indexer')
   call add(g:pathogen_disabled, 'vimprj')
endif

" load all plugins with pathogen
call pathogen#infect(s:sPath.'/bundle')

" ----------------------------------------------------------------

" делаем так, чтобы в норм. режиме Ctrl+Shift+6 переключал раскладку
noremap <C-^>  a<C-^><Esc>

" set autoindent

set autoindent
filetype plugin indent on

" -------------------------- guifont ----------------------------
if has('win32') || has('win64')
   set guifont=Consolas:h9:cRUSSIAN
else
   set guifont=Consolas\ 10
endif
"set guifont=Courier\ New\ Cyr
"set guifont=Terminus:h12:cRUSSIAN

" ---------------------------------------------------------------

" ---------------- мапим клавиши для переключения буферов по Ctrl-Tab -----
"if 0
"map <silent> <C-Tab> :BufExplorer<CR>j
"map <silent> <C-S-Tab> :BufExplorer<CR>k
"augroup BufExplorerAdd
"if !exists("g:BufExploreAdd")
"let g:BufExploreAdd = 1
"au BufWinEnter \[BufExplorer\] map <buffer> <Tab> <CR>
"" FIXME: Subsequent invocations fail with this autoselect for some reason.
"" Navigate to the file under the cursor when you let go of Tab
""au BufWinEnter \[BufExplorer\] set updatetime=1000
"" o is the BufExplorer command to select a file
""au! CursorHold \[BufExplorer\] normal o
"endif
"augroup END
"endif

" ---------------- Buffet -----------------
"
" see    bundle/custom_buffet/plugin/buffet_addon.vim


" ---------------- SelectBuf (actually i don't use it) -----------------

nmap <unique> <silent> <F7> <Plug>SelectBuf

" -------------------------- omnicppcompletion ----------------------------
let OmniCpp_SelectFirstItem     = 2  " select first item but not insert to code
"
" OmniCppComplete
let OmniCpp_NamespaceSearch     = 1
let OmniCpp_GlobalScopeSearch   = 1
let OmniCpp_ShowAccess          = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot      = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow    = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope    = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces   = ["std", "_GLIBCXX_STD"]
let OmniCpp_LocalSearchDecl     = 1
" automatically open and close the popup menu / preview window
"au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
"set completeopt=menuone,menu,preview
set completeopt=menuone,menu

" -------------- useful functions -------------

" Check if symbols are defined, and confirm error if some of them are not.
" Usage example:
"
"  call CheckNeededSymbols(
"           \  "The following items needs to be defined in your vimfiles/machine_local_conf/current/variables.vim file to make things work: ",
"           \  "",
"           \  [
"           \     '$MACHINE_LOCAL_CONF__PATH__MINGW_INCLUDE',
"           \  ]
"           \  )
function! CheckNeededSymbols(sTextBefore, sTextAfter, lSymbols)
   let sErrorText = ""

   for sSymbol in a:lSymbols
      if !exists(sSymbol)
         if strlen(sErrorText) > 0
            let sErrorText .= ", "
         endif
         let sErrorText .= sSymbol
      endif
   endfor

   if strlen(sErrorText) > 0
      let sErrorText = a:sTextBefore . sErrorText . a:sTextAfter
      call confirm(sErrorText)
   endif
endfunction

" -------------- alias -------------
exec('source '.s:sPath.'/bundle/cmdalias/plugin/cmdalias.vim')
call CmdAlias('BD',   'bd')
call CmdAlias('bd',   'Kwbd')
call CmdAlias('cw',   'botright cw')
call CmdAlias('ee',   'e %:p:h')
call CmdAlias('ef',   'FFS')
call CmdAlias('calc', 'Calc')

" buffer delete without closing window
nmap <C-W><Backspace> <Plug>Kwbd

" highlight tabs and trailing spaces
set list listchars=tab:>-,trail:.,extends:>,precedes:<

" copy indent from previous line: useful when using tabs for indentation
" and spaces for alignment
set copyindent

" ------------------------ persistent undo -----------------------
" Перенесен в _vimrc_small
" ----------------------------------------------------------------

function! <SID>VimwikiSurround(symbol)
   if visualmode() =~ '\Cv'
      exe "normal gvs".a:symbol
   elseif visualmode() =~ '\CV'
      " TODO: add {{{ }}}
   endif
endfunction

" --- some functions dependent on filetype.
"     local to buffer options is better to set in OnFileTypeChanged(), but
"     global options should be set in OnBufEnter.
function! <SID>OnBufEnter()

   " for C and C++ files set nolazyredraw, because clang_complete works buggy
   " with it
   if (              &ft == "c" 
            \     || &ft == "cpp" 
            \  )
      " maybe nolazyredraw even not needed here, let's see.
      "set nolazyredraw
      set lazyredraw
   else
      set lazyredraw
   endif


endfunction

function! <SID>OnFileTypeChanged()

   " do it for any buffer, because if we do it only for sources, then I
   " might mistakenly use <Leader>p in non-source file (by habit), and
   " this won't work.
   noremap <Leader>p p
   noremap <Leader>P P

   " для исходников ремапим p и P, чтобы вставляемый текст автоматически выравнивался
   if (              &ft == "c" 
            \     || &ft == "cpp" 
            \     || &ft == "vim" 
            \     || &ft == "php" 
            \     || &ft == "dosbatch" 
            \     || &ft == "javascript"
            \     || &ft == "cs"
            \     || &ft == "java"
            \     || &ft == "xml"
            \     || &ft == "ruby"
            \     || &ft == "eruby"
            \     || &ft == "css"
            \     || &ft == "scss"
            \  )
      noremap <buffer> P Pmp=']`p
      noremap <buffer> p pmp=']`p
   endif

   " для некоторых типов файлов ремапим "}", чтобы после закрытия фиг. скобки
   " текст сам выравнивался.

   if (              &ft == "c" 
            \     || &ft == "cpp" 
            \     || &ft == "php" 
            \     || &ft == "javascript"
            \     || &ft == "cs"
            \     || &ft == "java"
            \     || &ft == "css"
            \     || &ft == "scss"
            \     || &ft == "ruby"
            \  )

      "imap <buffer> } }<Esc>mt=%`ta
      imap <buffer> } <C-R>=AutoPairsInsert('}')<CR><Esc>mt=%`ta<C-R>=AutoPairsInsCntUndoReset()<CR>
   else
      " NOTE: since we use auto-pairs, we anyway need to map }
      imap <buffer> } <C-R>=AutoPairsInsert('}')<CR>
   endif

   if (              &ft == "vimwiki" 
            \  )
      nmap <buffer> <C-j> <Plug>VimwikiNextLink
      nmap <buffer> <C-k> <Plug>VimwikiPrevLink

      setl wrap

      inoremap <buffer> <C-g>i * [ ] 

      inoremap <buffer> <C-g>h1 =  =<Left><Left>
      inoremap <buffer> <C-g>h2 ==  ==<Left><Left><Left>
      inoremap <buffer> <C-g>h3 ===  ===<Left><Left><Left><Left>
      inoremap <buffer> <C-g>h4 ====  ====<Left><Left><Left><Left><Left>

      " single-line code markup
      " vmap <buffer> <C-k> s`
      " vmap <buffer> <C-k> :<C-u>if visualmode() == 'v' | normal gvs` | endif
      vmap <buffer> <C-k> :<C-u>call <SID>VimwikiSurround("`")<CR>
      vmap <buffer> <C-b> :<C-u>call <SID>VimwikiSurround("*")<CR>
      vmap <buffer> <C-i> :<C-u>call <SID>VimwikiSurround("_")<CR>

   endif


   " for nerdtree use <Esc> for quit and <Backspace> for go up-by-tree
   if (              &ft == "nerdtree" 
            \  )
      map <buffer> <Esc> q
      map <buffer> <BS>  u
   endif


endfunction


autocmd! BufEnter * call <SID>OnBufEnter()
autocmd! FileType * call <SID>OnFileTypeChanged()


"set diffexpr=MyDiff()
"function! MyDiff()
   "let opt = '-a --binary '
   "if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
   "if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
   "let arg1 = v:fname_in
   "if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
   "let arg2 = v:fname_new
   "if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
   "let arg3 = v:fname_out
   "if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
   "let eq = ''
   "if $VIMRUNTIME =~ ' '
      "if &sh =~ '\<cmd'
         "let cmd = '""' . $VIMRUNTIME . '/diff"'
         "let eq = '"'
      "else
         "let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '/diff"'
      "endif
   "else
      "let cmd = $VIMRUNTIME . '/diff'
   "endif
   "silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
"endfunction

" ------------------ свои команды diff -------------------
" нужны потому, что стандартная :diffoff включает wrap,
" не знаю, почему.

function! s:DiffThisWindow(on)
   if a:on
      silent! set diff scrollbind cursorbind " fdm=diff
   else
      silent! set nodiff noscrollbind nocursorbind " fdm=syntax
   end

   silent! setl foldmethod=marker
   silent! setl foldcolumn=0
   silent! setl scrollopt-=hor
   silent! setl nowrap

endfunc

if exists(':Diffthis') != 2
   command -nargs=? -complete=file Diffthis call <SID>DiffThisWindow(1)
endif

if exists(':Diffoff') != 2
   command -nargs=? -complete=file Diffoff call <SID>DiffThisWindow(0)
endif

if exists(':Diff1') != 2
   command -nargs=? -complete=file Diff1 call <SID>DiffThisWindow(1)
endif

if exists(':Diff0') != 2
   command -nargs=? -complete=file Diff0 call <SID>DiffThisWindow(0)
endif

" command :wso   for   :w | so %

command -nargs=? -complete=file WSO :w | so %
call CmdAlias('wso', 'WSO')

" --------------------- backup --------------------------
" включить сохранение резервных копий
set backup

" сохранять умные резервные копии ежедневно
function! BackupDir()

   " определим каталог для сохранения резервной копии
   if has('win32') || has('win64')
      let l:backupdir=$VIM.'/backup/'.
               \substitute(expand('%:p:h'), '\:', '~', '')
   else
      let l:backupdir=$HOME.'/.vim/backup/'.
               \substitute(expand('%:p:h'), '^'.$HOME, '~', '')
   endif

   " если каталог не существует, создадим его рекурсивно
   if !isdirectory(l:backupdir)
      call mkdir(l:backupdir, 'p', 0700)
   endif

   " переопределим каталог для резервных копий
   let &backupdir=l:backupdir

   " переопределим расширение файла резервной копии
   let &backupext=strftime('~%Y-%m-%d_%H-%M-%S~')
endfunction

" выполним перед записью буффера на диск
autocmd! bufwritepre * call BackupDir()

" запретим folding
"autocmd BufEnter * set nofen
"set nofen

" заменим виндовый обратный слеш на простой слеш 
" (для совместимости с Unix-like systems)
if exists('+shellslash')
   set shellslash
endif


" -------------------- клавиши для компиляции ------------------
" map <F7> :make<Cr>
" -------------- перемещение по элементам в quickfix -----------
map <C-j> :cn<Cr>zvzz:cc<Cr>
map <C-k> :cp<Cr>zvzz:cc<Cr>

" -------------- insertion of brackets --------------
inoremap <C-G>{         {<CR>}<C-O><S-O>
inoremap <C-G><CR>      <CR><Esc>=%o<C-R>=AutoPairsInsCntUndoReset()<CR>
"inoremap <C-S-G>{    {<CR>};<C-O><S-O>

inoremap <C-G>}      <CR>}<C-O><S-O>

inoremap <C-G>d      do<CR>end<C-O><S-O>

" ---- листание элементов выпадающего списка с помощью Ctrl+j, Ctrk+k   -----
"        может, закомментить? т.к., оказывается, есть Ctrl-p, Ctrl-n
"        и вообще, :h popupmenu-keys
inoremap <silent> <C-j> <C-R>=pumvisible() ? "\<lt>Down>" : "\<lt>C-j>"<CR>
inoremap <silent> <C-k> <C-R>=pumvisible() ? "\<lt>Up>"   : "\<lt>C-k>"<CR>

"inoremap <silent> <C-d> <C-R>=pumvisible() ? "\<lt>Down>\<lt>Down>\<lt>Down>\<lt>Down>" : "\<lt>C-d>"<CR>
"inoremap <silent> <C-u> <C-R>=pumvisible() ? "\<lt>Up>\<lt>Up>\<lt>Up>\<lt>Up>" : "\<lt>C-u>"<CR>

inoremap <silent> <C-f> <C-R>=pumvisible() ? "\<lt>PageDown>" : "\<lt>C-f>"<CR>
inoremap <silent> <C-b> <C-R>=pumvisible() ? "\<lt>PageUp>" : "\<lt>C-b>"<CR>


" in insert mode, we can use <C-h> instead of <Backspace>.
" (this is built-in functionality)
"
" It would be logically to use <C-l> instead of <Del> then.
inoremap <C-l>    <Del>

" ----------- antlr filetype ----------

autocmd! BufRead    *.g4   set filetype=antlr4
autocmd! BufNewFile *.g4   set filetype=antlr4

" ----------- указываем тип php для файлов шаблонов ----------
autocmd! BufRead    *.tpl  set filetype=php
autocmd! BufNewFile *.tpl  set filetype=php
autocmd! BufRead    *._tp  set filetype=php
autocmd! BufNewFile *._tp  set filetype=php

" ----------- asm type for *.ash files
autocmd! BufRead    *.ash  set filetype=asm
autocmd! BufNewFile *.ash  set filetype=asm

autocmd! BufRead    *vimperatorrc* set filetype=vim
autocmd! BufNewFile *vimperatorrc* set filetype=vim

autocmd! BufRead    *pentadactylrc* set filetype=vim
autocmd! BufNewFile *pentadactylrc* set filetype=vim

" ----------- vifm filetype ----------

autocmd! BufRead    vifmrc   set filetype=vim
autocmd! BufRead    *.vifm   set filetype=vim

" When switching buffers, preserve window view.
if v:version >= 700
   "au BufLeave * let b:winview = winsaveview() | call confirm("saved ".expand('%')." ".b:winview['topline'])
   "au BufEnter * if exists('b:winview') | call confirm("restoring ".expand('%')." ".b:winview['topline']) | call winrestview(b:winview) | call confirm("restored") | endif
endif




" ---------- feature from vimbits.com -----------

" Show syntax highlighting groups for word under cursor 
nnoremap <silent> <F10> :call <SID>SynStack()<CR>
function! <SID>SynStack()
   if !exists("*synstack")
      return
   endif
   echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" ------------------------ persistent undo -----------------------
" (этот конфиг persistent undo здесь, потому что была идея сделать так,
" чтобы файлы undo появлялись в директории .vimprj, но есть проблемы с тем,
" что будут постоянные лишние коммиты)
"
" включаем только если версия >= 7.3
if v:version >= 703
   " включим опцию persistent undo
   set undofile

   " сделаем так, чтобы файлы undo появлялись не в текущей директории, а в нашей
   if has('win32') || has('win64')
      let s:undodir=$VIM.'/undofiles'
   else
      let s:undodir=$HOME.'/.vim/undofiles'
   endif
   let &undodir=s:undodir

   " если каталог не существует, создадим его рекурсивно
   if !isdirectory(s:undodir)
      call mkdir(s:undodir, 'p', 0700)
   endif
endif


function! <SID>Write_and_make()
   :w
   :mak
endfunction

command -nargs=? -complete=file Wm call <SID>Write_and_make()
call CmdAlias('wm', 'Wm')

" handle *.md files as markdown ones
au BufRead,BufNewFile *.md set filetype=markdown

" --------------------------------------------------------- "
"                    настройка плагинов                     "
" --------------------------------------------------------- "

" --------------------- clang_complete ---------------------

" 
" Download win32 binaries:
" http://www.ishani.org/web/articles/code/clang-win32/  (look for "Download the most recent release")
"
" --- OR ---
" download ctags.exe here: (put in PATH, for instance, C:\WINDOWS\system32\)
" http://code.google.com/p/rxwen-blog-stuff/downloads/detail?name=clang.exe&can=2&q=
"
" download libclang.dll here: (put in PATH, for instance, C:\WINDOWS\system32\)
" http://code.google.com/p/rxwen-blog-stuff/downloads/detail?name=libclang.dll&can=2&q=
" ----------
"
"
"let g:clang_auto_user_options = 'path, .clang_complete, clang'
let g:clang_auto_user_options = ''

let g:clang_debug_confirm     = 1         " echo clang command and output (works if only g:clang_use_library == 0)
let g:clang_use_library       = 1         " use libclang instead of binary clang
                                          " (works much faster, and without
                                          " issues with calling system() in completefunc)

let g:clang_sort_algo         = "alpha"   " sort by alphabet (but I would prefer the order
                                          " in which fields are declared in the code)

let g:clang_complete_macros   = 1         " complete macros
let g:clang_auto_select       = 1         " select first item, but not insert in code

let g:clang_complete_auto     = 0

" on windows, clang binary needs shellslash to be turned OFF.
" but, clang library works well.
if has('win32') || has('win64')
   if !g:clang_use_library
      set noshellslash
   endif
endif

" use snippets in completion.
" what is "dfrank_code_complete" - this is autoload script, 
" bundle/clang_complete_dfadd/autoload/snippets/dfrank_code_complete.vim
let g:clang_snippets = 1
let g:clang_snippets_engine = 'dfrank_code_complete'

"let g:clang_auto_select = 2

"" Reparse the current translation unit in background
"command Parse
         "\ if &ft == 'c'                 |
         "\   call g:ClangBackgroundParse() |
         "\ else                            |
         "\   echom 'Parse What?'           |
         "\ endif

"" Reparse the current translation unit and check for errors
"command ClangCheck
         "\ if &ft == 'c'                 |
         "\   call g:ClangUpdateQuickFix()  |
         "\ else                            |
         "\   echom 'Check What?'           |
         "\ endif

"noremap  <silent> <F3> :Parse<cr>

" --------------------- qthelp ---------------------

if has('win32') || has('win64')
   let g:qthelp_browser = $MACHINE_LOCAL_CONF__CMD__BROWSER
else
   "let's try to leave it empty
   "let g:qthelp_browser = 'firefox'
endif

let g:qthelp_tags = $MACHINE_LOCAL_CONF__PATH__QT_DOC_TAGS

call CmdAlias('qt', 'QHelp')
nnoremap <C-q>    :QHelpOnThis<CR>

" --------------------- surround ---------------------

" после изменения скобок текст будет выровнен (с помощью = )
let b:surround_indent = 1  


" --------------------- textobj-user ---------------------

"call textobj#user#plugin('foo', {
         "\   'cdata': {
         "\     '*pattern*': ['<!\[CDATA\[', '\]\]>'],
         "\     'select-a': 'aC',
         "\     'select-i': 'iC',
         "\   },
         "\   'date': {
         "\     '*pattern*': '\<\d\{4}-\d\{2}-\d\{2}\>',
         "\     'select': ['ad', 'id'],
         "\   },
         "\   'helptag': {
         "\     '*pattern*': '\*[^*]\+\*',
         "\     'move-n': ',j',
         "\     'move-p': ',k',
         "\     'move-N': ',J',
         "\     'move-P': ',K',
         "\   },
         "\   '-': {
         "\     '*select-function*': 'SelectFoo',
         "\     'select': ['ax', 'ix'],
         "\   },
         "\ })

call textobj#user#plugin('dfrank', {
         \   'C_multiline_comment': {
         \     '*pattern*': ['\v(\/\*+\s*\n\s*\*+\s*|\/\*\s{0,1})', '\v(\n\s*\*+\/|\s{0,1}\*\/)'],
         \     'select-a': 'a*',
         \     'select-i': 'i*',
         \   },
         \   'C_comment': {
         \     '*pattern*': ['\v\/\/\s*', '\v.$'],
         \     'select-a': 'a/',
         \     'select-i': 'i/',
         \   },
         \   'C_preprocessor': {
         \     '*pattern*': ['\v^\s*\#\s*(if).*\n', '\v\n\s*\#\s*(endif).*$'],
         \     'select-a': 'a#',
         \     'select-i': 'i#',
         \   },
         \   'func_param': {
         \     '*pattern*': '\v([()]|\,\s)@<=[^(),]+[(),]@=',
         \     'select': ['aP', 'iP'],
         \   },
         \   'operand': {
         \     '*pattern*': '\v[a-zA-Z0-9_.\->\[\]&]+',
         \     'select': ['ao', 'io'],
         \   },
         \ })

"\     '*pattern*': '\v([()]|\,\s{0,1})@<=[^(),]+[(),]@=',

" -------------------- BufExplorer --------------------------

" 0000-00-00
" *sdfsdf*
" <![CDATA[  sdf sdf ]]>
" *sdfsdf*
" /*sd fsdfsd

" */
let g:bufExplorerShowTabBuffer = 1   " show only buffers for this tab
let g:bufExplorerFindActive = 0      " Do not go to active window.

" --------------------- Project -----------------------------

" imst - по дефолту, я добавил:
" "v" для использования vimgrep вместо grep
" "c" для того, чтобы после выбора файла окно проекта закрывалось
let g:proj_flags='imstvc'

" замапим F9 на показать-скрыть окно проекта
" NOTE: mapping has been moved to <SID>SetMainDefaults()

" --------------------- Taglist -----------------------------

"" замапим F8 на показать-скрыть окно taglist
"nmap <silent> <F8> :Tlist<cr>
"" показываем окно taglist справа
"let Tlist_Use_Right_Window = 1

"let g:Tlist_Show_One_File=1                         " показывать информацию только по одному файлу
"let g:Tlist_GainFocus_On_ToggleOpen=1               " получать фокус при открытии
"let g:Tlist_Compact_Format=1
"let g:Tlist_Close_On_Select=0                       " не закрывать окно после выбора тега
"let g:Tlist_Auto_Highlight_Tag=1                    " подсвечивать тег, на котором сейчас находимся

" --------------------- Tagbar -----------------------------

" замапим F8 на показать-скрыть окно taglist
nmap <F8> :TagbarToggle<cr>
" показываем окно taglist справа

let g:tagbar_autofocus = 1               " получать фокус при открытии

" --------------------- Lineup (text align plugin) -----------

"--map Lineup to Space and Shift+Space 
vmap <Space> :call LineupPrompt()<CR>
vmap <S-Space> :call LineupREPrompt()<CR>

" --------------------- vim-easy-align -----------

vnoremap <silent> <Enter> :EasyAlign<Enter>

" --------------------- VimCommander -----------------------------

noremap <silent> <F11> :call VimCommanderToggle()<CR>

command -nargs=? -complete=file Vc call VimCommanderToggle()
call CmdAlias('vc', 'Vc')

" --------------------- JavaGetSet -----------------------------------

let g:javagetset_getterTemplate = 
         \ "\n" .
         \ "%modifiers% %type% %funcname%(){\n" .
         \ "   return %varname%;\n" .
         \ "}"

let g:javagetset_setterTemplate = 
         \ "\n" .
         \ "%modifiers% void %funcname%(%type% %varname%){\n" .
         \ "   this.%varname% = %varname%;\n" .
         \ "}"

" --------------------- NERDTree -----------------------------

let NERDTreeShowHidden = 1             " show hidden files
let NERDTreeQuitOnOpen = 1             " close NERDTree window when user selects file
call CmdAlias('nt', 'NERDTreeToggle')  

" make NERD tree ignore some files.
" By default it is ['\~$'], but I also hate "." and ".." items
" (they happens on Windows only without &shellslash)
let NERDTreeIgnore = ['\~$', '\v^\.$', '\v^\.\.$']

" --------------------- Gundo -----------------------------------

nnoremap <F6> :GundoToggle<CR>

" --------------------- Undotree -----------------------------------

nnoremap <F5> :UndotreeToggle<CR>
let g:undotree_DiffAutoOpen = 0
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_TreeNodeShape = 'o'

" --------------------- projectCTags (not my plugin) ------------
"map  <F3>  :call GenerateProjectCTags( "Standard", "" )<CR> 
"map  <F4>  :call GenerateProjectCTags( "Exclude Stuff", "--languages=C,C++ --exclude=folder1 --exclude=folder2" )<CR> 

let g:projectCTagsAutogenerateTags = 1

" --------------------- javacomplete ------------------------
if has("autocmd")
   autocmd Filetype java setlocal omnifunc=javacomplete#Complete
endif

" --------------------- easygrep ----------------------------

let g:EasyGrepRecursive = 1     " recursive
let g:EasyGrepMode = 2          " Tracked mode (depending on extension)

" if we have 'grep' executable, use it instead of vimgrep,
" because it is MUCH more faster.
if (executable('grep') || executable('grep.exe'))
   let g:EasyGrepCommand = 1       " grep instead of vimgrep
else
   let g:EasyGrepCommand = 0       " use vimgrep
endif

"let g:EasyGrepFileAssociations = s:sPath.'/bundle/easygrep_dfadd/EasyGrepFileAssociations_dfrank'
let g:EasyGrepSearchCurrentBufferDir = 0  " search in cwd only

" --------------------- indexer ----------------------------

let g:indexer_shortProjParentNames = 1

" --------------------- SmartHomeKey ----------------------------
" настройки этого плагина выше





"let g:indexer_debugLogLevel = 2
"let g:indexer_debugLogFilename = 'd:\log_tmp.txt'

"let g:indexer_ctagsDontSpecifyFilesIfPossible=1
"let g:indexer_dirNameForSearch=".vimprj"
"let g:indexer_lookForProjectDir =0
"let g:indexer_indexerListFilename=expand('$HOME') . '/.vim_indexer'

" --------------------- rename ---------------------

call CmdAlias('rename', 'Rename')

" --------------------- vimprj ---------------------

let g:vimprj_changeCurDirIfVimprjFound = 1

"let g:sErrorFormatDefault = &errorformat

function! <SID>SetMainDefaults()

   if &filetype != 'ruby' && &filetype != 'eruby' && &filetype != 'css' && &filetype != 'scss' && &filetype != 'python'
      set tabstop=2         " размер таба - 4
      set shiftwidth=2      " ширина отступа - 4 пробела
   else
      set tabstop=2
      set shiftwidth=2
   endif
   set expandtab         " юзаем пробелы вместо символов таб

   " C indenting: "normal" switch formatting  :help cino-:
   set cino=
   
   " set default errorformat option
   "let &errorformat = g:sErrorFormatDefault

   compiler gcc

   " set env.variable LC_ALL = 'C', to make gcc echo messages in english
   let $LC_ALL='C'   

   " замапим F9 на показать-скрыть окно проекта
   nmap <silent> <F9> <Plug>ToggleProject

   set colorcolumn=

   " ------------------------ vimwiki -----------------------

   let dHomeVimwiki = 
            \  {
            \     'maxhi': 0,
            \     'css_name': 'style.css',
            \     'auto_export': 0,
            \     'diary_index': 'diary',
            \     'template_default': '',
            \     'nested_syntaxes': {},
            \     'diary_sort': 'desc',
            \     'path': '~/vimwiki/',
            \     'diary_link_fmt': '%Y-%m-%d',
            \     'template_ext': '',
            \     'syntax': 'default',
            \     'custom_wiki2html': '',
            \     'index': 'index',
            \     'diary_header': 'Diary',
            \     'ext': '.wiki',
            \     'path_html': '',
            \     'temp': 0,
            \     'template_path': '',
            \     'list_margin': -1,
            \     'diary_rel_path': 'diary/'
            \  }

   let g:vimwiki_list_ignore_newline = 0
   let g:vimwiki_list = [
            \  dHomeVimwiki,
            \  dHomeVimwiki,
            \  ]

   if (!exists('g:vimprj_env__paths'))
      let g:vimprj_env__paths = []
   endif

   " clear FileFastSelector paths
   let g:FFS_paths = []

   " ----------------------------------------------------------------

   "call confirm("ts: ".&ts)
endfunction

"call <SID>SetMainDefaults()

try
   call vimprj#init()
   function! g:vimprj#dHooks['SetDefaultOptions']['main_options'](dParams)
      call <SID>SetMainDefaults()
      "call confirm("SetDefaultOptions")
      "echon a:dParams
      "call confirm("done")
   endfunction

   function! g:vimprj#dHooks['OnAfterSourcingVimprj']['main_options'](dParams)
      "call confirm("OnAfterSourcingVimprj")
      "echon a:dParams
      "call confirm("done")
   endfunction

   function! g:vimprj#dHooks['OnAddNewVimprjRoot']['main_options'](dParams)
      "call confirm('OnAddNewVimprjRoot')
   endfunction
catch
endtry

" --------------------- EasyMotion -----------------------------

"let g:EasyMotion_leader_key = ','
let g:EasyMotion_do_shade = 0
hi EasyMotionTarget   ctermfg=yellow ctermbg=red cterm=bold gui=bold guibg=Red guifg=yellow

let g:EasyMotion_mapping_t = ',t'
let g:EasyMotion_mapping_T = ',T'
let g:EasyMotion_mapping_w = ',w'
let g:EasyMotion_mapping_W = ',W'
let g:EasyMotion_mapping_b = ',b'
let g:EasyMotion_mapping_B = ',B'
let g:EasyMotion_mapping_e = ',e'
let g:EasyMotion_mapping_E = ',E'
let g:EasyMotion_mapping_ge = ',ge'
let g:EasyMotion_mapping_gE = ',gE'
let g:EasyMotion_mapping_j = ',j'
let g:EasyMotion_mapping_k = ',k'
let g:EasyMotion_mapping_n = ',n'
let g:EasyMotion_mapping_N = ',N'

let g:EasyMotion_keys  = ''
let g:EasyMotion_keys .= 'abcdefghijklmnopqrstuwxz'
let g:EasyMotion_keys .= 'ABCDEFGHIJKLMNOPQRSTUWXZ'
let g:EasyMotion_keys .= '123456789'
let g:EasyMotion_keys .= "[];'\,./"
let g:EasyMotion_keys .= '{}:"|<>?'
let g:EasyMotion_keys .= '!@#$%^&*()_+'

" --------------------- PreciseJump ----------------------------
"let g:PreciseJump_I_am_brave = 1

"nmap <leader>F :call PreciseJumpF(0, 0, 0)<cr>
"vmap <leader>F <ESC>:call PreciseJumpF(0, 0, 1)<cr>
"omap <leader>F :call PreciseJumpF(0, 0, 0)<cr>

"nmap <leader>f :call PreciseJumpF(-1, -1, 0)<cr>
"vmap <leader>f <ESC>:call PreciseJumpF(-1, -1, 1)<cr>
"omap <leader>f :call PreciseJumpF(-1, -1, 0)<cr>

"nmap <leader>t :call PreciseJumpT(-1, -1, 0)<cr>
"vmap <leader>t <ESC>:call PreciseJumpT(-1, -1, 1)<cr>
"omap <leader>t :call PreciseJumpT(-1, -1, 0)<cr>

nmap ,F :call PreciseJumpF(0, 0, 0)<cr>
vmap ,F <ESC>:call PreciseJumpF(0, 0, 1)<cr>
omap ,F :call PreciseJumpF(0, 0, 0)<cr>

nmap ,f :call PreciseJumpF(-1, -1, 0)<cr>
vmap ,f <ESC>:call PreciseJumpF(-1, -1, 1)<cr>
omap ,f :call PreciseJumpF(-1, -1, 0)<cr>

"nmap ,t :call PreciseJumpT(-1, -1, 0)<cr>
"vmap ,t <ESC>:call PreciseJumpT(-1, -1, 1)<cr>
"omap ,t :call PreciseJumpT(-1, -1, 0)<cr>

let g:PreciseJump_target_keys  = ''
let g:PreciseJump_target_keys .= 'abcdefghijklmnopqrstuwxz'
let g:PreciseJump_target_keys .= 'ABCDEFGHIJKLMNOPQRSTUWXZ'
let g:PreciseJump_target_keys .= '123456789'
let g:PreciseJump_target_keys .= "[];'\,./"
let g:PreciseJump_target_keys .= '{}:"|<>?'
let g:PreciseJump_target_keys .= '!@#$%^&*()_+'

" --------------------- ObviousResize ----------------------------

"noremap <silent> <C-Up> :ObviousResizeUp<CR> 
"noremap <silent> <C-Down> :ObviousResizeDown<CR> 
"noremap <silent> <C-Left> :ObviousResizeLeft<CR> 
"noremap <silent> <C-Right> :ObviousResizeRight<CR>

" ----------------- php-doc ----------------
"source $VIM/vimfiles/plugin/php-doc.vim 
"inoremap <C-P> <ESC>:call PhpDocSingle()<CR>i 
"nnoremap <C-P> :call PhpDocSingle()<CR> 
"vnoremap <C-P> :call PhpDocRange()<CR>

" --------------------- syntax html ----------------------------

let html_no_rendering = 1
let html_very_easy    = 1


" --------------------- eclim ------------------------

" Use temp files for autocompletion, instead of modifying actual file
let g:EclimTempFilesEnable = 1

" Levels:
" <= 0: No output.
" >= 1: Fatal errors.
" >= 2: Errors.
" >= 3: Warning messages.
" >= 4: Info messages.
" >= 5: Debug messages.
" >= 6: Trace messages.
let g:EclimSignLevel = 3   " Warning messages

let g:EclimXmlIndentDisabled = 1
let g:EclimLargeFileEnabled = 0  " this setting should be 0 by default, but it is not it current version,
                                 " so, Eric suggested me to add this line.

if !exists('$MY_ECLIPSE_HOME')
   if (has('win32') || has('win64'))
      let $MY_ECLIPSE_HOME = 'D:/eclipse'
   else
      let $MY_ECLIPSE_HOME = '/home/dimon/download/eclipse/eclipse'
   endif
endif

"let g:EclimAntCompilerAdditionalErrorFormat =
         "\ '\%A%.%#[xslt]\ Loading\ stylesheet\ %f,' .
         "\ '\%Z%.%#[xslt]\ %.%#:%l:%c:\ %m,'


let g:EclimJavaCompleteDotComplete = 1
let g:EclimJavaCompleteSelectFirstItem = 2
let g:EclimJavaCompleteFuncSignature = 1

" Ctrl-Shift-F10 should insert missing imports, like Esclipse does this by Ctrl-Shift-O
map <C-S-F10> :JavaImportOrganize<cr>

" Ctrl-F10 should insert import for symbol under cursor
map <C-F10>   :JavaImport<cr>

" Open search results in the current window
"let g:EclimJavaSearchSingleResult = 'edit'
let g:EclimDefaultFileOpenAction = 'edit'

" smart Ctrl+] for Java:  Ctrl+[
" noremap <C-[> :JavaSearchContext<CR>

" --------------------- vimwiki ------------------------

let g:vimwiki_hl_headers = 1           " use vimwiki's built-in colors for headers highlighting
nmap <Leader>wn <Plug>VimwikiNextLink

"let g:vimwiki_list[0]['nested_syntaxes'] = {'c++': 'cpp'}


" --------------------- autocomplpop ------------------------
" -- commented because buggy: try to type some word, wait for autocompletion,
"    and then delete the word by typing <Backspace>. You will be unable to delete
"    first 1 or 2 chars of the word.
"        let g:acp_mappingDriven = 1

" --------------------- maximize ----------------------------

" let g:loaded_maximize=1

" --------------------- delimitMate ----------------------------

" do not insert closing element automatically, but place cursor in the middle
" if matching element was typed by hand.
"     read this:  :help delimitMateAutoClose
let delimitMate_autoclose = 0    

" --------------------- autocomplpop ----------------------------

"let g:acp_behavior = {
         "\  'c'          : [],
         "\  'cpp'        : [],
         "\  'vim'        : [],
         "\  'php'        : [],
         "\  'dosbatch'   : [],
         "\  'javascript' : [],
         "\  'cs'         : [],
         "\  'java'       : [],
         "\  'asm'        : [],
         "\  'ash'        : [],
         "\  'antlr4'     : [],
         "\  'vimwiki'    : [],
         "\  'eruby'      : [],
         "\  'pascal'     : [],
         "\  }

let g:acp_behavior = {}

" we don't need to add xml here, because it is added
" by default

for key in keys(g:acp_behavior)
   call add(g:acp_behavior[key], {
            \   'command'      : "\<C-x>\<C-u>",
            \   'completefunc' : 'acp#completeSnipmate',
            \   'meets'        : 'acp#meetsForSnipmate',
            \   'onPopupClose' : 'acp#onPopupCloseSnipmate',
            \   'repeat'       : 0,
            \ })
endfor

"for key in keys(g:acp_behavior)
   "call add(g:acp_behavior[key], {
            "\   'command'      : "\<C-x>\<C-u>",
            "\   'completefunc' : 'acp#completeSnipmate',
            "\   'meets'        : 'acp#meetsForSnipmate',
            "\   'onPopupClose' : 'acp#onPopupCloseSnipmate',
            "\   'repeat'       : 0,
            "\ })
"endfor
"---------------------------------------------------------------------------
for key in keys(g:acp_behavior)
   call add(g:acp_behavior[key], {
            \   'command' : "\<C-n>",
            \   'meets'   : 'acp#meetsForKeyword',
            \   'repeat'  : 0,
            \ })
endfor
"---------------------------------------------------------------------------
for key in keys(g:acp_behavior)
   call add(g:acp_behavior[key], {
            \   'command' : "\<C-x>\<C-f>",
            \   'meets'   : 'acp#meetsForFile',
            \   'repeat'  : 1,
            \ })
endfor


let g:acp_behavior['*'] = []
"let g:acp_behaviorRubyOmniMethodLength = -1
"let g:acp_behavior['ruby'] = []

" --------------------- FileFastSelector ----------------------------

let g:FFS_ignore_list = ['.*', '*.bak', '~*', '*~', '*.obj', '*.pdb', '*.res', '*.dll', '*.idb', '*.exe', '*.lib', '*.suo', '*.sdf', '*.exp', '*.so', '*.pyc', 'CMakeFiles', '*.o', '*.o.*', '*.class']

augroup FFS_Add
   if !exists("g:FFS_Dfrank_Added")
      let g:FFS_Dfrank_Added = 1


      " -- map Ctrl+K, Ctrl+J to behave like up/down
      au BufWinEnter FastFileSelector inoremap <buffer> <C-K> <Up>
      au BufWinEnter FastFileSelector inoremap <buffer> <C-J> <Down>

      " -- map <Esc> to quit the window
      au BufWinEnter FastFileSelector noremap  <buffer> <Esc> :q<CR>
      au BufWinEnter FastFileSelector inoremap <buffer> <Esc> <Esc>:q<CR>

   endif
augroup END

" --------------------- MRU ----------------------------

augroup MRU_Add
   if !exists("g:MRU_Dfrank_Added")
      let g:MRU_Dfrank_Added = 1

      " -- map <Esc> to quit the window
      au BufWinEnter __MRU_Files__ noremap  <buffer> <Esc> :q<CR>
      au BufWinEnter __MRU_Files__ inoremap <buffer> <Esc> <Esc>:q<CR>

   endif
augroup END

" --------------------- airline ---------------------
" (not used right now)
let g:airline_theme="bubblegum"


" --------------------- ultisnips ---------------------

let g:UltiSnipsExpandTrigger       = "<C-E>"
let g:UltiSnipsListSnippets        = "<C-Tab>"
let g:UltiSnipsJumpForwardTrigger  = "<c-e>"
let g:UltiSnipsJumpBackwardTrigger = "<c-u>"


" --------------------- easyclip (not used right now) ---------------------

let g:EasyClipUseCutDefaults = 0


" --------------------- autopairs ---------------------

"let g:AutoPairsMapCR = 0
let g:AutoPairsCenterLine = 0
let g:AutoPairsDelRepeatedPairs = 0
let g:AutoPairsUseInsertedCount = 1

" --------------------- php-indent ---------------------
" (not used right now)

:let g:PHP_outdentphpescape = 0

" --------------------- rainbow ---------------------

let g:rainbow_active = 0

" --------------------- surfer ---------------------

let g:surfer_generate_tags = 0

" --------------------- prettyprint ---------------------

" add functions and commands for PrettyPrint-ing comma-separated strings
function! PrettyPrintCommas(...)
   let result = []

   for expr in a:000
      if type(expr) == type("")
         call add(result, split(expr, ','))
      else
         call add(result, expr)
      endif
      unlet expr
   endfor
   return call('PrettyPrint', result)
endfunction

function! PPC(...)
   return call('PrettyPrintCommas', a:000)
endfunction

command! -nargs=+ -bang -complete=expression PrettyPrintCommas PPC<bang> <args>
command! -nargs=+ -bang -complete=expression PPC echo PPC(<args>)

" --------------------- code_complete ---------------------

let g:completekey = '<S-Tab>'

" --------------------- fpc support ---------------------
"  COMMENTED because syntax file was just renamed to 'pascal.vim' from
"  'delphi.vim', and this produces no issues. NOTE that there were issues with
"  matchit plugin if we set ft to 'delphi' instead of 'pascal'

"" Pascal / Delphi
"if (1==1) "change to "1==0" to use original syntax
   "au BufNewFile,BufRead *.pas,*.PAS set ft=delphi
"else
   "au BufNewFile,BufRead *.pas,*.PAS set ft=pascal
"endif
"" Delphi project file
"au BufNewFile,BufRead *.dpr,*.DPR set ft=delphi
"" Delphi form file
"au BufNewFile,BufRead *.dfm,*.DFM set ft=delphi
"au BufNewFile,BufRead *.xfm,*.XFM set ft=delphi
"" Delphi package file
"au BufNewFile,BufRead *.dpk,*.DPK set ft=delphi
"" Delphi .DOF file = INI file for MSDOS
"au BufNewFile,BufRead *.dof,*.DOF set ft=dosini
"au BufNewFile,BufRead *.kof,*.KOF set ft=dosini
"au BufNewFile,BufRead *.dsk,*.DSK set ft=dosini
"au BufNewFile,BufRead *.desk,*.DESK set ft=dosini
"au BufNewFile,BufRead *.dti,*.DTI set ft=dosini
"" Delphi .BPG = Makefile
"au BufNewFile,BufRead *.bpg,*.BPG set ft=make|setlocal makeprg=make\ -f\ % 

" disable backspace, delete, etc
"COMMENTED_BS: disabled backspace on purpose, to get used to C-H
"NOTE: in order to enable BS back, grep for COMMENTED_BS, and you'll get
"other places where you need to uncomment it
":inoremap <BS> <Nop>
":inoremap <Del> <Nop>
":inoremap <PageDown> <Nop>
":inoremap <PageUp> <Nop>
":inoremap <Up> <Nop>
":inoremap <Down> <Nop>
":inoremap <Left> <Nop>
":inoremap <Right> <Nop>
":nnoremap <BS> <Nop>
":nnoremap <Del> <Nop>
":nnoremap <PageDown> <Nop>
":nnoremap <PageUp> <Nop>
":nnoremap <Up> <Nop>
":nnoremap <Down> <Nop>
":nnoremap <Left> <Nop>
":nnoremap <Right> <Nop>

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_loclist_height = 10

" --------------------- vim-jsx ---------------------

" enable JSX stuff even for *.js files
let g:jsx_ext_required = 0

" --------------------- vim-go ---------------------

" use mkview / loadview before and after running gofmt, so that folds state
" gets preserved
let g:go_fmt_experimental = 1
let g:go_def_mode = 'godef'
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1

" --------------------- vim-gurl ---------------------

let g:vimgurl_yank_register = '+'

set guioptions-=r
set guioptions-=L
