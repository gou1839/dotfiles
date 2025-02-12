let g:NERDTreeShowHidden = 1
let NERDTreeWinSize=21

function! SmartNERDTree()
  " ファイルが指定されていない、かつディレクトリが指定されている場合のみNERDTreeを開く
  if argc() == 0
    NERDTree
    wincmd p
  endif
endfunction

augroup nerdtree
  autocmd!
  autocmd FileType nerdtree setlocal signcolumn=auto
  autocmd VimEnter * call SmartNERDTree()
  autocmd VimEnter * wincmd p
augroup END
