set nocompatible

"--------
" vundle
"--------
filetype off "required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" github.com
Bundle 'gmarik/vundle'
Bundle 'nanotech/jellybeans.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'Lokaltog/vim-powerline'
Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimproc'
Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/neosnippet'

" vim.org
Bundle 'JavaScript-syntax'
Bundle 'sudo.vim'

filetype plugin indent on "required!

"--------
" visual
"--------
colorscheme jellybeans
set number
set t_Co=256
syntax on
set showmatch
set showcmd
set laststatus=2
"set statusline=%F%m%r%h%w\%=[TYPE=%Y]\[FORMAT=%{&ff}]\[ENC=%{&fileencoding}]\[LOW=%l/%L]
set notitle

"--------
" editor
"--------
set tabstop=2
set shiftwidth=2
set expandtab
set clipboard+=unnamed
set wildmenu
set nobackup

"--------
" search
"--------
nnoremap <C-L> :nohl<CR><C-L>
set incsearch
set hlsearch
set ignorecase
set smartcase
set autoindent

"--------
" plugin
"--------
let g:neocomplcache_enable_at_startup = 1

" neosnippet key mappings
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets befavior
imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" for snippet_complete marker
if has('conceal')
  set conceallevel=2 concealcursor=i
endif


