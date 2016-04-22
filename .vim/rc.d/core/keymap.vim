imap <c-h> <Left>
imap <c-j> <Down>
imap <c-k> <Up>
imap <c-l> <Right>

" Paste
imap <F12> <nop>
set pastetoggle=<F12>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Make double-<Esc> clear search highlights
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>
vnoremap * "zy:let @/ = @z<CR>n
