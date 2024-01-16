" be iMproved, required. Do not allow compatibility with Vi style APIs.
set nocompatible

filetype off " required

" When a file has been detected to have been changed outside of Vim and it has
" not been changed inside of Vim, automatically read it again.
set autoread

" do not make a backup before overwriting a file.
set nobackup

" Do not want a backup while the file is being written.
set nowritebackup

" |:noswapfile| modifier can be used to not create a swapfile for a new buffer.
set noswapfile

" update every 10 ms
set updatetime=10


"      ********************************************************************
"    *************************************************************************
"  ********************************** PLUGINS **********************************
"    *************************************************************************
"      ********************************************************************

" set the runtime path to include Vundle and initialize. View with `:set
" runtimepath`
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" A solid language pack for Vim.
Plugin 'sheerun/vim-polyglot'

" fugitive.vim: A Git wrapper so awesome, it should be illegal
Plugin 'https://github.com/tpope/vim-fugitive'

" rhubarb.vim: GitHub extension for fugitive.vim
Plugin 'https://github.com/tpope/vim-rhubarb'

" A Vim plugin that provides GraphQL file detection, syntax highlighting, and
" indentation.
Plugin 'jparise/vim-graphql'

" Typescript syntax files for Vim
" Plugin 'leafgarland/typescript-vim'

" surround.vim: quoting/parenthesizing made simple
Plugin 'tpope/vim-surround'

" Shows git diff markers in the sign column and stages/previews/undoes hunks and
" partial hunks.
Plugin 'https://github.com/airblade/vim-gitgutter.git'

" lean & mean status/tabline for vim that's light as air
Plugin 'vim-airline/vim-airline'

" A collection of themes for vim-airline
Plugin 'vim-airline/vim-airline-themes'

" Vim script for text filtering and alignment
Plugin 'godlygeek/tabular'

" Syntax checking hacks for vim
Plugin 'scrooloose/syntastic'

" Generate some lorem in your docs
Plugin 'loremipsum'

" commentary.vim: comment stuff out
Plugin 'tpope/vim-commentary'

" A Vim plugin for TypeScript
Plugin 'quramy/tsuquyomi'

" abolish.vim: easily search for, substitute, and abbreviate multiple variants
" of a word
Plugin 'tpope/vim-abolish'

" A code-completion engine for Vim
Plugin 'ycm-core/YouCompleteMe'

" ???
Plugin 'koron/nyancat-vim'

" Run your tests at the speed of thought
Plugin 'vim-test/vim-test'

" Vim plugin, provides insert mode auto-completion for quotes, parens, brackets,
" etc.
Plugin 'raimondi/delimitmate'

" Auto close (X)HTML tags
Plugin 'alvan/vim-closetag'

Plugin 'andrewradev/tagalong.vim'

" precision colorscheme for the vim text editor
Plugin 'altercation/vim-colors-solarized'

" An arctic, north-bluish clean and elegant Vim theme.
Plugin 'arcticicestudio/nord-vim'

" fzf <3 vim
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" Markdown preview plugin for Vim
Plugin 'skanehira/preview-markdown.vim'

" Prisma support for Vim
Plugin 'prisma/vim-prisma'

" All of your Plugins must be added before the following line
call vundle#end()            " required

filetype plugin indent on    " required

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
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

  " For all files set 'textwidth' (tw) to a default of 80 characters.
  set textwidth=80

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

  " Set filetype specific indentation
  autocmd FileType md setlocal shiftwidth=2 tabstop=2
  autocmd FileType go setlocal shiftwidth=4 tabstop=4

else
  set autoindent " always set autoindenting on
endif " has("autocmd")

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif

"      ********************************************************************
"    *************************************************************************
"  ********************************* MY CONFIG *********************************
"    *************************************************************************
"      ********************************************************************

" Enable indentation in insert mode
inoremap <C-T> <C-O>:><CR>
inoremap <C-R> <C-O>:<<CR>

" Regenerate *.spl binary if does not exist or modified time > *.add modified
for d in glob('~/.vim/spell/*.add', 1, 1)
    if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
        exec 'mkspell! ' . fnameescape(d)
    endif
endfor

" insert single space after ".", "?", or "!" when joining lines
set nojoinspaces

" alias tabnew to tn
cnoreabbrev tn tabnew

" Visual command line completion
set wildmenu

" ignore case when matching patterns supplied to find, find/replace
set ignorecase

" character case is considered if pattern contains any upper case characters
set smartcase

" set history table to 1000 entries
set history=1000

" set the window's title, reflecting the file currently being edited.
set title

" show the cursor position all the time
set ruler

" display incomplete commands
set showcmd

" do incremental searching
set incsearch

" cursor settings
" change cursor in iTerm2
if $TERM_PROGRAM =~ "iTerm"
  let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
  let &t_SR = "\<Esc>]50;CursorShape=2\x7" " Underscore on replace mode
  let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif

" change cursor in native Apple Terminal
if $TERM_PROGRAM =~ "Apple_Terminal"
  let &t_SI.="\e[5 q" "SI = INSERT mode
  let &t_SR.="\e[4 q" "SR = REPLACE mode
  let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)
endif

" change cursor in Gnome Terminal version ≥ 3.16
if has("autocmd")
  au VimEnter,InsertLeave * silent execute '!echo -ne "\e[1 q"' | redraw!
  au InsertEnter,InsertChange *
    \ if v:insertmode == 'i' |
    \   silent execute '!echo -ne "\e[5 q"' | redraw! |
    \ elseif v:insertmode == 'r' |
    \   silent execute '!echo -ne "\e[3 q"' | redraw! |
    \ endif
  au VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
endif

" change cursor in Alacritty
if $COLORTERM =~ "truecolor"  " assume we're in Alacritty or kitty if this is in env
  let &t_SI = "\<esc>[6 q" "SI = INSERT mode
  let &t_SR = "\<esc>[4 q" "SR = REPLACE mode
  let &t_EI = "\<esc>[0 q" "EI = NORMAL mode (ELSE)
endif

" KEYMAPS

" Up and down by 10 rows
nmap <C-J> 10j
nmap <C-K> 10k
vmap <C-J> 10j
vmap <C-K> 10k

" set cursorline and cursorcolumn
nmap <leader>c :set cursorcolumn! cursorline!<CR>

" Hide search highlighting for the current search
nmap <leader>n :noh<CR>

" Toggle spell check and highlight
nmap <leader>s :set spell!<CR>


" NAVIGATION
" easier switching between splits
nmap <C-W> <C-W><C-W>

" Navigate back to end of previous word
nnoremap <S-B> gE

" easier tab navigation with vim keybindings for let and right
nmap <C-H> g<S-T>
nmap <C-L> gt

" Move by rows instead of lines (much more intuitive with 'wrap')
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> <Down> v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap <expr> <Up> v:count ? 'k' : 'gk'


" copy current filename to system register (clipboard)
nmap ,cs :let @+=expand("%")<CR>

" copy full path of current file to system register
nmap ,cl :let @+=expand("%:p")<CR>

" copy project path and file name of current buffer to system register
" nmap <leader>f :let @+=expand(f)<CR> <--- does not work

" tab for native autocomplete selection
imap <expr> <Tab> ((pumvisible())?("\<C-y>"):("<Tab>"))

" delete next character in insert mode (delete forward)
inoremap <C-d> <Del>

" set something something register to copy to system clipboard
set clipboard=unnamed


" FORMATTING

" wrap lines on whole words
set linebreak


" STYLING

" spellcheck by default
set spell

" show line numbers by default
set number

" use relative line numbers
set relativenumber

" toggle relative and absolute line numbers on pane focus (works with tmux
" focus-events) from https://jeffkreeftmeijer.com/vim-number/
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained * set relativenumber
  autocmd BufLeave,FocusLost   * set norelativenumber
augroup END

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Colors and stuff

" themes
set background=light
colorscheme solarized

" conditionally set undercurl mode when using solarized
function! GetColorSchemeName()
    try
        return g:colors_name
    catch /^Vim:E121/
        return "default"
    endtry
endfunction

if GetColorSchemeName() == 'solarized'
  set t_Cs=",underline"
endif

" Airline theme
" let g:airline_theme='solarized_flood'

" For indents that consist of 2 space characters but are entered with the tab key
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab


" REGISTERS
"
" clear all named registers
function! ClrRegs()
  let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
  for r in regs
    call setreg(r, [])
  endfor
endfunction

if !exists(":ClearRegs")
  command ClearRegs call ClrRegs()
endif

" NATIVE netrw

" use tree view as native view
let g:netrw_liststyle = 3

" Vim Tab Configuration
" :command Tn tabnew

" OTHER SETTINGS

" stop modeline errors
set nomodeline

" F2 to toggle paste mode
set pastetoggle=<F2>

" \p to toggle paste mode
nnoremap <Leader>p :set paste!<CR>


" FUNCTIONS
command! Dbg call Ignore()
function! Ignore()
   normal! o
   normal! oimport ipdb
   normal! oipdb.set_trace()

endfunction


" PLUGIN SETTINGS
" ***************

" YCM
" remaps
nmap gd :YcmCompleter GoTo<CR>
nmap gr :YcmCompleter GoToReferences<CR>

" Experiment with ths direct ycm to open GoTo commands in a new tab.
let g:ycm_goto_buffer_command = 'split-or-existing-window'

" explicitly whitelist files
let g:ycm_filetype_whitelist = {
  \ "python":1,
\ }

" Close preview window after completion
let g:ycm_autoclose_preview_window_after_completion=1

" Use tags file for identifier lookup. Does this work??
let g:ycm_collect_identifiers_from_tags_files=1

" white list ycm_extra_conf files
let g:ycm_extra_conf_globlist = ['~/Source/*']


" GitGutter

" sign column color for solarized-light themes in Alacritty

" setting color by number indicates picking from the 256 color set available
" to the terminal

" colors for solarized_light
highlight SignColumn ctermbg=lightgrey
highlight GitGutterAdd ctermfg=34 ctermbg=lightgrey
highlight GitGutterChange ctermfg=208 ctermbg=lightgrey
highlight GitGutterDelete ctermfg=red ctermbg=lightgrey

" colors for solarized dark
" highlight SignColumn ctermbg=8
" highlight GitGutterAdd ctermfg=34 ctermbg=8
" highlight GitGutterChange ctermfg=208 ctermbg=8
" highlight GitGutterDelete ctermfg=red ctermbg=8

" after opening and entering a hunk preview, close preview pane with <esc>
let g:gitgutter_close_preview_on_escape=1

nnoremap ]c :GitGutterNextHunk<CR>
nnoremap [c :GitGutterPrevHunk<CR>


" Vim Markdown

" To disable the folding configuration for the ft-markdown-plugin:
" let g:vim_markdown_folding_disabled = 1
" let g:markdown_folding = 1


" fzf

nmap <C-P> :Files<CR>

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)


" SYNTAX/SYNTASTIC/EXTERNAL SYNTAX SETTINGS

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" checkers
let g:syntastic_python_checkers = ['flake8']
" let g:syntastic_md_checkers = []
let g:syntastic_markdown_checkers = []
let g:syntastic_sh_checkers = ["shellcheck", "sh"]
let g:syntastic_sh_shellcheck_args = '-x'
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_typescript_checkers = ['eslint']
" let g:syntastic_typescript_eslint_args=['--cache']
" let g:syntastic_javascript_eslint_exe = './node_modules/.bin/eslint .'
" let g:syntastic_typescript_eslint_exe = 'eslint'


func! s:SetBreakpoint()
    cal append('.', repeat(' ', strlen(matchstr(getline('.'), '^\s*'))) . 'import ipdb; ipdb.set_trace()')
endf

func! s:RemoveBreakpoint()
    exe 'silent! g/^\s*import\sipdb\;\?\n*\s*ipdb.set_trace()/d'
endf

func! s:ToggleBreakpoint()
    if getline('.')=~#'^\s*import\sipdb' | cal s:RemoveBreakpoint() | el | cal s:SetBreakpoint() | en
endf

nnoremap <C-B> :call <SID>ToggleBreakpoint()<CR>

" kitty settings
if $TERM =~ "xterm-kitty"
  colorscheme solarized
  set background=dark

  let g:airline_theme='solarized_flood'

  " colors for solarized dark
  highlight SignColumn ctermbg=8
  highlight GitGutterAdd ctermfg=34 ctermbg=8
  highlight GitGutterChange ctermfg=208 ctermbg=8
  highlight GitGutterDelete ctermfg=red ctermbg=8
endif

" enable exrc for project specific .vimrc files
set exrc

" enable secure to prevent autocmd commands in local rc files
set secure

