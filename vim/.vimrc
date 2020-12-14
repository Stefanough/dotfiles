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
Plugin 'tpope/vim-surround'

" Fuzzy file, buffer, mru, tag, etc finder
Plugin 'https://github.com/ctrlpvim/ctrlp.vim.git'

" Shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks.
Plugin 'https://github.com/airblade/vim-gitgutter.git'

" lean & mean status/tabline for vim that's light as air
Plugin 'vim-airline/vim-airline'

" A collection of themes for vim-airline
Plugin 'vim-airline/vim-airline-themes'

" Vim script for text filtering and alignment
Plugin 'godlygeek/tabular'

" For vim-markdown
Plugin 'plasticboy/vim-markdown'

" Syntax checking hacks for vim
Plugin 'scrooloose/syntastic'

" Generate some lorem in your docs
Plugin 'loremipsum'

" NERDTree
Plugin 'preservim/nerdtree'

" A plugin of NERDTree showing git status
" Plugin 'Xuyuanp/nerdtree-git-plugin'

" commentary.vim: comment stuff out
Plugin 'tpope/vim-commentary'

" Make terminal vim and tmux work better together.
Plugin 'tmux-plugins/vim-tmux-focus-events'

" abolish.vim: easily search for, substitute, and abbreviate multiple variants of a word
" https://github.com/tpope/vim-abolish
Plugin 'tpope/vim-abolish'

" A code-completion engine for Vim
Plugin 'ycm-core/YouCompleteMe'

" ???
Plugin 'koron/nyancat-vim'

" precision colorscheme for the vim text editor
Plugin 'altercation/vim-colors-solarized'

" Run your tests at the speed of thought
Plugin 'vim-test/vim-test'

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

" ignorecase, smartcase
set ignorecase
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
if $COLORTERM =~ "truecolor"  " assume we're in Alacritty if this is in env
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

" Hide search highlighting for the current search
nmap <leader>n :noh<CR>

" Toggle spell check and highlight
nmap <leader>s :set spell!<CR>

" insert a space in normal mode:
nmap <space> i<space><esc>


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

" native autocomplete on tab
imap <Tab> <C-N>
imap <S-Tab> <C-P>

" cariage return for native autocomplete selection
imap <expr> <CR> ((pumvisible())?("\<C-y>"):("<CR>"))


" set something something register to copy to system clipboard
set clipboard=unnamed


" FORMATTING

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

" themes
set background=dark
colorscheme solarized

" Airline theme
let g:airline_theme='solarized_flood'

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

" GitGutter

" sign column color for solarized-light themes in Alacritty

" setting color by number indicates picking from the 256 color set available
" to the terminal

" colors for solarized_light
" highlight SignColumn ctermbg=lightgrey
" highlight GitGutterAdd ctermfg=34 ctermbg=lightgrey
" highlight GitGutterChange ctermfg=208 ctermbg=lightgrey
" highlight GitGutterDelete ctermfg=red ctermbg=lightgrey

" colors for solarized dark
highlight SignColumn ctermbg=8
highlight GitGutterAdd ctermfg=34 ctermbg=8
highlight GitGutterChange ctermfg=208 ctermbg=8
highlight GitGutterDelete ctermfg=red ctermbg=8

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
"     \ "Ignored"   : "☒",
"     \ "Unknown"   : "?"
"     \ }


" vim-markdown-preview
let vim_markdown_preview_github=1
let vim_markdown_preview_browser='/Applications/Firefox.app/Contents/MacOS/firefox'


" CtrlP

" Open new files in a new tab
let g:ctrlp_open_new_file = 't'

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

" all the files
let g:ctrlp_max_files=0

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

set exrc
