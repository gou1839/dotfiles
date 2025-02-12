" デフォルトではauto-saveをOFFに
let g:auto_save = 0

" インサートモードでの自動保存を有効化
let g:auto_save_in_insert_mode = 0
" 自動保存を有効にしたいディレクトリのリスト
let g:auto_save_dirs = [
  \ '~/Programing/SurvivalTypeScript'
  \ ]

" ファイルを開いた時にディレクトリをチェックして自動保存を設定する関数
function! CheckAutoSaveDir()
  let l:file_path = expand('%:p:h')
  for dir in g:auto_save_dirs
    let l:expanded_dir = expand(dir)
    if l:file_path =~# '^' . l:expanded_dir
      let g:auto_save = 1
      return
    endif
  endfor
  let g:auto_save = 0
endfunction

" 自動コマンドグループを設定
augroup auto_save_specific_dirs
  autocmd!
  autocmd BufRead,BufNewFile * call CheckAutoSaveDir()
augroup END
