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
Bundle 'honza/snipmate-snippets'
"Bundle 'vim-ruby/vim-ruby'

" vim.org
Bundle 'JavaScript-syntax'
Bundle 'sudo.vim'
Bundle 'molokai'

filetype plugin indent on "required!

"--------
" visual
"--------
colorscheme molokai
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
set backspace=indent,eol,start

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
"--------------------------------------------------neocomplcache
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_auto_completion_start_length = 1
if !exists('g:neocomplcache_plugin_completion_length')
  let g:neocomplcache_plugin_completion_length = {
        \ 'snippets_complete' : 1, 
        \ 'buffer_complete' : 2, 
        \ 'syntax_complete' : 2, 
        \ 'tags_complete' : 3, 
        \ }
endif

" Define keyword, for minor languages
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" neosnippet key mappings
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets befavior
imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" for snippet_complete marker
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" Tell Neosnippet about the othre snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/snipmate-snippets/snippets'

