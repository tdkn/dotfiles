" Plugins
" ==================================================
call plug#begin('~/.vim/plugged')
" Basic amenities
Plug 'tpope/vim-sensible'

" Appearance
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'bling/vim-airline'
Plug 'scrooloose/nerdtree'
Plug 'gcmt/taboo.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'gregsexton/MatchTag'
Plug 'bronson/vim-trailing-whitespace'

" Git
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Utils
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()

" Core
" ==================================================
silent! colorscheme hybrid_material
