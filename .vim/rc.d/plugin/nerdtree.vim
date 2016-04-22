" Plugin key-mapping.
map <C-n> :NERDTreeToggle<CR>

let NERDTreeShowBookmarks=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1

let file_name = expand("%")
if has('vim_starting') && file_name == ""
  autocmd VimEnter * NERDTree ./
endif
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
