" normal settings
set nowrap 
syntax on " turn on syntax highlighting
set expandtab " convert tabs to spaces
set tabstop=4 " width for tabs
set softtabstop=4 " see multiple spaces as tabstops
set shiftwidth=4 " width for autoindents
set autoindent " indent new line same amount as previous line
set copyindent " 
set number " show line numbers
set showcmd " 
set backup " store backup files
set noswapfile " disable swap file 
set showmatch " show matches
set nocompatible "disable vi compatibility
set clipboard=unnamedplus " use system clipboard
set ttyfast " speed up scrolling
set wildmode=longest,list " bash-like autocompletions
filetype plugin indent on " auto-indent depends on filetype and plugins
set cursorline " shows line cursor is on
set scrolloff=5 " always show atleast five lines above/below the cursor

" status line
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

call plug#begin('~/.config/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mhinz/vim-startify'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'preservim/nerdcommenter'
Plug 'tmhedberg/matchit'
Plug 'sheerun/vim-polyglot'
Plug 'Pocco81/AutoSave.nvim'
call plug#end()

" open nerdtree by default on file open
augroup nerdtree_open
    autocmd!
    autocmd VimEnter * NERDTree | wincmd p
augroup END

let mapleader=','
