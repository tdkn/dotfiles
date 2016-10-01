"---------------
" visual
"---------------
set background=dark
silent! colorscheme hybrid_material
set cursorline
"set nocursorline
set showmatch
set showcmd
set list
set listchars=trail:_,tab:>-
set notitle
set nowrap
set number
set splitbelow
set splitright
set t_Co=256

"---------------
" file
"---------------
set noswapfile
set encoding=utf-8

"---------------
" edit
"---------------
if $TMUX == ''
  set clipboard=unnamed,autoselect
endif
set expandtab
set mouse=a
set nobackup
set shiftwidth=2
set tabstop=2
set whichwrap+=<,>,[,]

set ttyfast
set ttyscroll=3
set lazyredraw " to avoid scrolling problems

"---------------
" search
"---------------
set hlsearch
set ignorecase
set incsearch
set smartcase
