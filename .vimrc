" have to install vim-plug https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')
Plug 'Yggdroot/indentLine'
call plug#end()

set nowrap
set nocompatible " i like my arrow keys tyvm
syntax on
"filetype indent plugin on
set background=dark
colorscheme cobalt
"set number
"set numberwidth=5
"set relativenumber
set tabstop=4
set autoindent
set copyindent
set expandtab
set shiftwidth=4
set so=2
set history=1000 " length of history

function! GitBranch()
    return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatusLineGit()
    let l:branchname = GitBranch()
    return strlen(l:branchname) > 0?'  '.l:branchname.'  ':''
endfunction

set laststatus=2
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatusLineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ [%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\


" Skeletons
au BufNewFile *.c,*.cpp,*.cc,*.java
    \ 0r ~/.vim/skeletons/skel.c
    \ | %s/YEAR/\=strftime("%Y")/g
    \ | %s/TODAY/\=strftime("%d %B %Y")/g
    \ | %s/FILENAME/\=expand("%:t")/g
    \ | $
au BufNewFile *.go
    \ 0r ~/.vim/skeletons/skel.go
    \ | %s/YEAR/\=strftime("%Y")/g
    \ | %s/TODAY/\=strftime("%d %B %Y")/g
    \ | %s/FILENAME/\=expand("%:t")/g
    \ | $
au BufNewFile *.h,*.hpp
    \ 0r ~/.vim/skeletons/skel.h
    \ | %s/YEAR/\=strftime("%Y")/g
    \ | %s/TODAY/\=strftime("%d %B %Y")/g
    \ | %s/FILENAME_H/\=toupper(expand("%:t:r"))."_".toupper(expand("%:t:e"))/g
    \ | %s/FILENAME/\=expand("%:t")/g
    \ | 10
au BufNewFile *.sh,*.bash
    \ 0r ~/.vim/skeletons/skel.sh
    \ | %s/YEAR/\=strftime("%Y")/g
    \ | %s/TODAY/\=strftime("%d %B %Y")/g
    \ | %s/FILENAME/\=expand("%:t")/g
    \ | $
au BufNewFile *.py
    \ 0r ~/.vim/skeletons/skel.py
    \ | %s/YEAR/\=strftime("%Y")/g
    \ | %s/TODAY/\=strftime("%d %B %Y")/g
    \ | %s/FILENAME/\=expand("%:t")/g
    \ | $
au BufNewFile *.sql
    \ 0r ~/.vim/skeletons/skel.sql
    \ | %s/TODAY/\=strftime("%d %B %Y")/g
    \ | %s/FILENAME/\=expand("%:t:r")/g
    \ | $

" autocomplete parentheses and quotations
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
