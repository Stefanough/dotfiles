" be iMproved, required. Do not allow compatability with Vi style APIs.
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

" update every 100 ms
set updatetime=100


" PLUGINS

" set the runtime path to include Vundle and initialize. View with `:set
" runtimepath`
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Typescript syntax files for Vim
Plugin 'leafgarland/typescript-vim'

" vim-javascript installed 2018-04-29
Plugin 'https://github.com/pangloss/vim-javascript'

" surround.vim: quoting/parenthesizing made simple
Plugin 'https://github.com/tpope/vim-surround'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"
" Git wrapper for Vim. Provides Git commands in Vim command line.
Plugin 'tpope/vim-fugitive'

" Fast file navigation for VIM
" Plugin 'wincent/command-t'

" Fuzzy file, buffer, mru, tag, etc finder
Plugin 'https://github.com/ctrlpvim/ctrlp.vim.git'

" A Vim plugin which shows git diff markers in the sign column and stages/previews/undoes hunks and partial hunks.
Plugin 'https://github.com/airblade/vim-gitgutter.git'

" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

" lean & mean status/tabline for vim that's light as air
" https://github.com/vim-airline/vim-airline
Plugin 'bling/vim-airline'

" Vim script for text filtering and alignment
" https://github.com/godlygeek/tabular
Plugin 'godlygeek/tabular'

" For vim-markdown
" https://github.com/plasticboy/vim-markdown
Plugin 'plasticboy/vim-markdown'

" Solarized color scheme
" Plugin 'altercation/vim-colors-solarized'

" Syntastic
Plugin 'scrooloose/syntastic'

" Generate some lorem in your docs
Plugin 'loremipsum'

" Tag and block(?) matching
Plugin 'MatchTag'

" js-beautify plugin
" Plugin 'maksimr/vim-jsbeautify'

" try to get ESlint into vim

" NERDTree
Plugin 'preservim/nerdtree'

" A plugin of NERDTree showing git status
Plugin 'Xuyuanp/nerdtree-git-plugin'

" commentary.vim: comment stuff out
Plugin 'tpope/vim-commentary'

" A light Vim plugin for previewing markdown files in a browser - without leaving Vim.
" Plugin 'JamshedVesuna/vim-markdown-preview'

" Make terminal vim and tmux work better together.
 Plugin 'tmux-plugins/vim-tmux-focus-events'

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

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.

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

" Visual ommand line completion
set wildmenu

" set histroy table to 1000 entries
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

" KEYMAPS

" Hide search highlighting for the current search
nmap <leader>n :noh<CR>

" insert a space in normal mode:
nmap <space> i<space><esc>

" exit insert mode by double tapping jj
imap jj <right><esc>

" exit visual mode by double tapping mm
vmap mm <esc>

" delete all characters on line without removing line
nmap <S-X> 0D

" add new line above cursor without entering insert mode
" nmap oo o<esc>k

" add new line below cursor without entering insert mode
" nmap OO O<esc>j


" NAVIGATION
" easier switching between splits
nmap <C-W> <C-W><C-W>

" easier tab navigation with vim keybindings for lett and right
nmap <C-H> g<S-T>
nmap <C-L> gt

" Move by rows instead of lines (much more intuitive with 'wrap')
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> <Down> v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
nnoremap <expr> <Up> v:count ? 'k' : 'gk'


" copy current filename to system register (clipboard)
nmap ,cs :let @+=expand("%")<CR>

" copy full path of curent file to system register
nmap ,cl :let @+=expand("%:p")<CR>

" paste from vim register to begining of line
" nmap <C-P> 0P

" set something something register to copy to system clipboard
set clipboard=unnamed


" FORMATING

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
" foccus-events) from https://jeffkreeftmeijer.com/vim-number/
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained * set relativenumber
:  autocmd BufLeave,FocusLost   * set norelativenumber
:augroup END

" show cursor line
set cursorline

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Colors and stuff

set background=dark

" try to get Solarized working
" let g:solarized_termcolors=256
" set t_Co=256

" For indents that consist of 2 space characters but are entered with the tab key
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab

" To disable the folding configuration for the vim-markdown plugin:
let g:vim_markdown_folding_disabled = 1


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

" set paste on paste
" Creates weird delay when returning to normal mode from insert
" May have to change when using tmux
" https://szunyog.github.io/vim/vim-automatically-set-paste-mode
" let &t_SI .= "\<Esc>[?2004h"
" let &t_EI .= "\<Esc>[?2004l"

" inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

" function! XTermPasteBegin()
"   set pastetoggle=<Esc>[201~
"   set paste
"   return ""
" endfunction



" PLUGIN SETTINGS
" ***************

" GitGutter

" sign column color
highlight SignColumn ctermbg=black ctermfg=black
highlight GitGutterAdd ctermfg=green
highlight GitGutterDelete ctermfg=red

"
" NERDTree

" show hidden files by default
let NERDTreeShowHidden=1

" NERDTree-git-plugin
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }


" vim-markdown-preview
let vim_markdown_preview_github=1
let vim_markdown_preview_browser='/Applications/Firefox.app/Contents/MacOS/firefox'


" CtrlP
"
" Use this option to change the mapping to invoke CtrlP in |Normal| mode
let g:ctrlp_map = '<c-p>'

" Set the default opening command to use when pressing the above mapping
let g:ctrlp_cmd = 'CtrlP'

" Ignore node_modules, dist direcotories
let g:ctrlp_custom_ignore = {
      \ 'dir': '\v[\/](node_modules|dist|site-packages|__pycache__)$',
      \ }

" Use pwd (location where Vim was opened)
let g:ctrlp_working_path_mode=0

" SYNTAX/SYNTASTIC/EXTERNAL SYNTAX SETTINGS

" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" 
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_javascript_eslint_exe = 'npm run lint --'

