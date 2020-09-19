" be iMproved, required. Do not allow compatibility with Vi style APIs.
set nocompatible

filetype off                  " required

" When a file has been detected to have been changed outside of Vim and it has not been changed inside of Vim, automatically read it again.
set autoread

" do not make a backup before overwriting a file.
set nobackup

" Do not want a backup while the file is being written.
set nowritebackup

" |:noswapfile| modifier can be used to not create a swapfile for a new buffer.
set noswapfile

" update every 10 ms
set updatetime=10


" PLUGINS

" set the runtime path to include Vundle and initialize. View with `:set
" runtimepath`
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" A Vim plugin that provides GraphQL file detection, syntax highlighting, and indentation.
Plugin 'jparise/vim-graphql'

" Typescript syntax files for Vim
Plugin 'leafgarland/typescript-vim'

" vim-javascript installed 2018-04-29
Plugin 'https://github.com/pangloss/vim-javascript'

" surround.vim: quoting/parenthesizing made simple
Plugin 'https://github.com/tpope/vim-surround'

" Fuzzy file, buffer, mru, tag, etc finder
Plugin 'https://github.com/ctrlpvim/ctrlp.vim.git'

" A Vim plugin which shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks.
Plugin 'https://github.com/airblade/vim-gitgutter.git'

" lean & mean status/tabline for vim that's light as air
Plugin 'bling/vim-airline'

" Vim script for text filtering and alignment
Plugin 'godlygeek/tabular'

" For vim-markdown
Plugin 'plasticboy/vim-markdown'

" Syntax checking hacks for vim
Plugin 'scrooloose/syntastic'

" Generate some lorem in your docs
Plugin 'loremipsum'

" Tag and block(?) matching
Plugin 'MatchTag'

" NERDTree
Plugin 'preservim/nerdtree'

" A plugin of NERDTree showing git status
" Plugin 'Xuyuanp/nerdtree-git-plugin'

" commentary.vim: comment stuff out
Plugin 'tpope/vim-commentary'

" Make terminal vim and tmux work better together.
Plugin 'tmux-plugins/vim-tmux-focus-events'

" A Vim plugin for TypeScript 
Plugin 'quramy/tsuquyomi'

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

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else
  set autoindent " always set autoindenting on
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

"   ***********
"  *************
" ** MY CONFIG **
"  *************
"   ***********

" CONFIG

" Visual command line completion
set wildmenu

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
if $COLORTERM =~ "truecolor"  " assume we're in Alacritty if this is in env
  let &t_SI = "\<esc>[6 q" "SI = INSERT mode
  let &t_SR = "\<esc>[4 q" "SR = REPLACE mode
  let &t_EI = "\<esc>[0 q" "EI = NORMAL mode (ELSE)
endif

" KEYMAPS

" Blank line under current line no white space
nmap <CR> ojjk

" Blank line above current line no white space
nmap <CR> Ojjj

" Hide search highlighting for the current search
nmap <leader>n :noh<CR>

" Toggle spell check and highlight
nmap <leader>s :set spell!<CR>

" insert a space in normal mode:
nmap <space> i<space><esc>

" exit insert mode by double tapping jj
imap jj <right><esc>

" exit visual mode by double tapping mm
vmap mm <esc>

" delete all characters on line without removing line
nmap <S-X> 0D


" NAVIGATION
" easier switching between splits
nmap <C-W> <C-W><C-W>

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

" set something something register to copy to system clipboard
set clipboard=unnamed


" FORMATTING

" turn off auto-insertion of comment leader on newline
" set formatoptions-=cro

" wrap lines on whole words
set linebreak


" STYLING
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

set background=dark

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



" PLUGIN SETTINGS
" ***************

" GitGutter

" sign column color
highlight SignColumn ctermbg=black ctermfg=black
highlight GitGutterAdd ctermfg=green
highlight GitGutterDelete ctermfg=red

" after opening and entering a hunk preview, close preview pane with <esc>
let g:gitgutter_close_preview_on_escape=1


" Vim Markdown

" To disable the folding configuration for the vim-markdown plugin:
let g:vim_markdown_folding_disabled = 1


" NERDTree

" show hidden files by default
let NERDTreeShowHidden=1

" NERDTree-git-plugin
" let g:NERDGitStatusTreeIndicatorMapCustom = {
"     \ "Modified"  : "✹",
"     \ "Staged"    : "✚",
"     \ "Untracked" : "✭",
"     \ "Renamed"   : "➜",
"     \ "Unmerged"  : "═",
"     \ "Deleted"   : "✖",
"     \ "Dirty"     : "✗",
"     \ "Clean"     : "✔︎",
"     \ 'Ignored'   : '☒',
"     \ "Unknown"   : "?"
"     \ }


" vim-markdown-preview
let vim_markdown_preview_github=1
let vim_markdown_preview_browser='/Applications/Firefox.app/Contents/MacOS/firefox'


" CtrlP

" Use this option to change the mapping to invoke CtrlP in |Normal| mode
let g:ctrlp_map = '<c-p>'

" Set the default opening command to use when pressing the above mapping
let g:ctrlp_cmd = 'CtrlP'

" Ignore node_modules, dist directories
let g:ctrlp_custom_ignore = {
      \ 'dir': '\v[\/](node_modules|dist|site-packages|__pycache__)$',
      \ }

" Use pwd (location where Vim was opened)
let g:ctrlp_working_path_mode=0

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
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_typescript_checkers = ['eslint']
" let g:syntastic_typescript_eslint_args=['--cache']
" let g:syntastic_javascript_eslint_exe = './node_modules/.bin/eslint .'
" let g:syntastic_typescript_eslint_exe = 'eslint'
