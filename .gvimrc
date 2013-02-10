set guioptions-=T
set guioptions-=m
set guicursor=a:blinkon0

"--------
" font
"--------
set guifont=Ricty\ 12

"--------
" Window
"--------
" restore window size and position
"--------------------------------------------------
let g:save_window_file = expand('~/.vimwinpos')
augroup SaveWindow
  autocmd!
  autocmd VimLeavePre * call s:save_window()
  function! s:save_window()
    let options = [
      \'set columns=' . &columns,
      \'set lines=' . &lines,
      \'winpos ' . getwinposx() . ' ' . getwinposy(),
      \]
    call writefile(options, g:save_window_file)
  endfunction
augroup END

if filereadable(g:save_window_file)
  execute 'source' g:save_window_file
endif
