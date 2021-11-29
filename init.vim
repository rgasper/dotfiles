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

call plug#begin('~/.config/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mhinz/vim-startify'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'preservim/nerdcommenter'
Plug 'tmhedberg/matchit'
Plug 'sheerun/vim-polyglot'
Plug 'Pocco81/AutoSave.nvim'
Plug 'vim-airline/vim-airline'
Plug 'chrisbra/csv.vim'
Plug 'tpope/vim-fugitive'
call plug#end()

" open nerdtree by default on file open
augroup nerdtree_open
    autocmd!
    autocmd VimEnter * NERDTree | wincmd p
augroup END

let mapleader=','

" CoC config

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" CoC commands

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" goto definition
nmap <silent> gd <Plug>(coc-definition)
" Open definition in a split window
nmap <silent> gD :vsp<CR><Plug>(coc-definition)<C-W>L

" goto references 
nmap <silent> gr <Plug>(coc-references-used)
" Open references in a split window
nmap <silent> gR :vsp<CR><Plug>(coc-references-used)<C-W>L

" refactor symbol
nmap <silent> rn <Plug>(coc-refactor)

" Use K to show documentation in preview window.
nnoremap <silent> doc :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

