set nocompatible

"--------
" vundle
"--------
filetype off "required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

"--------------------------------------------------github.com
Bundle 'gmarik/vundle'
Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimproc'
Bundle 'Shougo/neocomplcache'
"Bundle 'Shougo/neosnippet'
"Bundle 'honza/snipmate-snippets'
Bundle 'pangloss/vim-javascript'
Bundle 'thinca/vim-quickrun'
Bundle 'tpope/vim-endwise'
Bundle 'mattn/zencoding-vim'
Bundle 'nanotech/jellybeans.vim'
Bundle 'altercation/vim-colors-solarized'
Bundle 'Lokaltog/vim-powerline'
Bundle 'scrooloose/nerdtree'
Bundle 'fuenor/im_control.vim'

"--------------------------------------------------vim.org
Bundle 'JavaScript-syntax'
Bundle 'sudo.vim'
Bundle 'molokai'
Bundle 'nginx.vim'

filetype plugin indent on "required!

"--------
" visual
"--------
syntax on
set t_Co=256
set background=dark
let g:solarized_termtrans=1
colorscheme solarized
"colorscheme molokai
set number
set showmatch
set showcmd
set laststatus=2
set notitle
set splitbelow
set splitright

"--------
" edit
"--------
set tabstop=2
set shiftwidth=2
set expandtab
set clipboard=unnamedplus,autoselect
set wildmenu
set mouse=a
set nobackup
set backspace=indent,eol,start
set whichwrap+=<,>,[,]

imap <c-h> <Left>
imap <c-j> <Down>
imap <c-k> <Up>
imap <c-l> <Right>

" copy & paste fix
imap <F12> <nop>
set pastetoggle=<F12>

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
" Launches neocomplcache automatically on vim startup.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underscore completion.
let g:neocomplcache_enable_underbar_completion = 1
" Sets minimum char length of syntax keyword.
let g:neocomplcache_min_syntax_length = 3

" Define keyword, for minor languages
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
imap <C-k>     <Plug>(neocomplcache_snippets_expand)
smap <C-k>     <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <expr><CR> neocomplcache#smart_close_popup() . "\<CR>"
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplcache#close_popup()
inoremap <expr><C-e> neocomplcache#cancel_popup()

""--------------------------------------------------neosnippet
" Plugin key-mappings.
"imap <C-k>     <Plug>(neosnippet_expand_or_jump)
"smap <C-k>     <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
"smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
"if has('conceal')
"  set conceallevel=2 concealcursor=i
"endif

"--------------------------------------------------snipmate-snippets
" Tell Neosnippet about the othre snippets
"let g:neosnippet#snippets_directory='~/.vim/bundle/snipmate-snippets/snippets'
 
"--------------------------------------------------NERDTree
let file_name = expand("%")
if has('vim_starting') && file_name == ""
  autocmd VimEnter * NERDTree ./
endif

"--------------------------------------------------RSense
let g:rsenseHome = expand('~/opt/rsense-0.3')
let g:rsenseUseOmniFunc = 1
" rubyの設定
if !exists('g:neocomplcache_omni_functions')
  let g:neocomplcache_omni_functions = {}
endif
let g:neocomplcache_omni_functions.ruby = 'RSenseCompleteFunction'

"--------------------------------------------------Nginx
autocmd BufRead,BufNewFile /etc/nginx/* set ft=nginx

"--------------------------------------------------vim-endwise
" https://github.com/tpope/vim-endwise/issues/22
"let g:endwise_no_mappings = 1
inoremap <expr><silent> <CR> <SID>my_cr_function()
function! s:my_cr_function()
  return pumvisible() ? neocomplcache#close_popup() . "\<CR>" : "\<CR>"
endfunction

"--------------------------------------------------im_control.vim
" Toggle japanese input fix-mode
inoremap <silent> <C-j> <C-r>=IMState('FixMode')<CR>

" IBus control by Python
let IM_CtrlIBusPython = 1

" timeout setting
set timeout timeoutlen=3000 ttimeoutlen=100

