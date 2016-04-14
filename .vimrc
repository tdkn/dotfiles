" ==================================================
" Plugins.
" ==================================================
call plug#begin('~/.vim/plugged')

" Basic
" --------------------------------------------------
Plug 'tpope/vim-sensible'

" Appearance
" --------------------------------------------------
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'bling/vim-airline'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'gcmt/taboo.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'gregsexton/MatchTag'
Plug 'bronson/vim-trailing-whitespace'

" Syntax
" --------------------------------------------------
Plug 'othree/html5.vim', { 'for': ['html', 'php'] }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'wavded/vim-stylus', { 'for': 'stylus' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'mxw/vim-jsx', { 'for': 'javascript.jsx' }
Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
Plug 'vim-scripts/smarty-syntax', { 'for': 'smarty' }

" Writing
" --------------------------------------------------
Plug 'mattn/emmet-vim', { 'for': ['html', 'php'] }
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-repeat'
Plug 'tyru/caw.vim'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --gocode-completer --tern-completer' }
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'ervandew/supertab'

" Git Integration
" --------------------------------------------------
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Util
" --------------------------------------------------
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'moll/vim-bbye'
Plug 'bling/vim-bufferline'

call plug#end()


" ==================================================
" Custom Configrations.
" ==================================================
let s:selfpath = fnamemodify(resolve(expand('<sfile>:p')),':h')
function! s:LoadCustomConfig()
  if !exists('g:loaded_custom_config')
    let &rtp.=','.s:selfpath.'/.vim'
    runtime! rc.d/core/*.vim
    runtime! rc.d/plugin/*.vim
    let g:loaded_custom_config = 1
  endif
endfunction

call s:LoadCustomConfig()
