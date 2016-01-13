"---------------
" Bundler
"---------------
" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
"--------------------------------------------------
" Recommended to install
NeoBundle 'Shougo/vimproc.vim', {
 \ 'build' : {
 \     'windows' : 'make -f make_mingw32.mak',
 \     'cygwin' : 'make -f make_cygwin.mak',
 \     'mac' : 'make -f make_mac.mak',
 \     'unix' : 'make -f make_unix.mak',
 \    },
 \ }

"--------------------------------------------------github.com
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Shougo/neocomplete'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'honza/vim-snippets'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tpope/vim-bundler'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'moll/vim-bbye'
NeoBundle 'tyru/restart.vim'
NeoBundle 'will133/vim-dirdiff'
NeoBundle 'djoshea/vim-autoread'
NeoBundle 'tpope/vim-fugitive'

" Edit
NeoBundle 'mattn/emmet-vim'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tyru/caw.vim'
NeoBundle 'bronson/vim-trailing-whitespace'

" Visual
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Xuyuanp/nerdtree-git-plugin'
NeoBundle 'bling/vim-airline'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'gorodinskiy/vim-coloresque'
NeoBundle 'gregsexton/MatchTag'
NeoBundle 'gcmt/taboo.vim'

" Colorscheme
NeoBundle 'tomasr/molokai'
NeoBundle 'jdkanani/vim-material-theme'
NeoBundle 'kristijanhusak/vim-hybrid-material'

" Syntax
NeoBundle 'scrooloose/syntastic'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'othree/html5.vim'
NeoBundle 'elzr/vim-json'
NeoBundle 'cakebaker/scss-syntax.vim'
NeoBundle 'wavded/vim-stylus'
NeoBundle 'digitaltoad/vim-jade'

" Bundles for TweetVim
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'basyura/twibill.vim'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'basyura/bitly.vim'
NeoBundle 'mattn/favstar-vim'
NeoBundle 'basyura/TweetVim'

"--------------------------------------------------vim.org
"NeoBundle 'JavaScript-syntax'
NeoBundle 'sudo.vim'
NeoBundle 'nginx.vim'
NeoBundle 'matchit.zip'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

"---------------
" visual
"---------------
silent! colorscheme hybrid_material
set nocursorline
set showmatch
set showcmd
set laststatus=2
set list
set listchars=trail:_,tab:>-
set notitle
set nowrap
set number
set splitbelow
set splitright
set t_Co=256
syntax on

"---------------
" file
"---------------
set noswapfile

"---------------
" edit
"---------------
set autoindent
set backspace=indent,eol,start
if $TMUX == ''
  set clipboard=unnamed,autoselect
endif
set expandtab
set mouse=a
set nobackup
set shiftwidth=2
set tabstop=2
set wildmenu
set whichwrap+=<,>,[,]

imap <c-h> <Left>
imap <c-j> <Down>
imap <c-k> <Up>
imap <c-l> <Right>

" copy & paste fix
imap <F12> <nop>
set pastetoggle=<F12>

"---------------
" moving
"---------------
" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"---------------
" search
"---------------
" Make double-<Esc> clear search highlights
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>
set hlsearch
set ignorecase
set incsearch
set smartcase
vnoremap * "zy:let @/ = @z<CR>n

"---------------
" plugin
"---------------
"--------------------------------------------------neocomplete
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

"--------------------------------------------------neosnippet
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" disable preview window
set completeopt-=preview

" fix
let g:neosnippet#enable_snipmate_compatibility  =1

" Tell Neosnippet about the othre snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

"--------------------------------------------------NERDTree
" Plugin key-mapping.
map <C-n> :NERDTreeToggle<CR>

let NERDTreeShowBookmarks=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1

let file_name = expand("%")
if has('vim_starting') && file_name == ""
  autocmd VimEnter * NERDTree ./
endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

"--------------------------------------------------Nginx
autocmd BufRead,BufNewFile /etc/nginx/* set ft=nginx

"--------------------------------------------------vim-endwise
" https://github.com/tpope/vim-endwise/issues/22
"let g:endwise_no_mappings = 1
inoremap <expr><silent> <CR> <SID>my_cr_function()
function! s:my_cr_function()
  return pumvisible() ? neocomplcache#close_popup() . "\<CR>" : "\<CR>"
endfunction

"--------------------------------------------------vim-quickrun
" horizontal split
let g:quickrun_config={'*': {'split': ''}}

"--------------------------------------------------caw.vim
" mapping \c : toggle comment
nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)


"--------------------------------------------------TweetVim
let g:tweetvim_display_icon = 1
let g:tweetvim_open_buffer_cmd = 'vsplit!'

" Open :Unite tweetvim
nnoremap <silent> t :Unite tweetvim<CR>

"--------------------------------------------------vim-airline
let g:airline_left_sep=''
let g:airline_right_sep=''

"--------------------------------------------------nerdtree-git-plugin
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "*",
    \ "Staged"    : "+",
    \ "Untracked" : "U",
    \ "Renamed"   : "R",
    \ "Unmerged"  : "=",
    \ "Deleted"   : "D",
    \ "Dirty"     : "x",
    \ "Clean"     : "-",
    \ "Unknown"   : "?"
    \ }

"--------------------------------------------------vim-gitgutter
" Turn off vim-gitgutter by default
let g:gitgutter_enabled = 0

" key mapping
map <leader>gg :GitGutterToggle<CR>
map <leader>gr :GitGutterToggle<CR>:GitGutterToggle<CR>
