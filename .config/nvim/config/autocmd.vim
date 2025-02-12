augroup terminal_settings
  autocmd!
  autocmd TermOpen * setlocal norelativenumber
  autocmd TermOpen * setlocal nonumber
  autocmd TermOpen * startinsert
  autocmd BufEnter term://* startinsert
  autocmd VimEnter * wincmd p
augroup END

function! SmartTerminalStart()
  " ファイルが指定されていない、かつディレクトリが指定されている場合のみターミナルを開く
  if argc() == 0
    call TerminalSplitWithCD()
    wincmd p
  endif
endfunction

augroup smart_terminal_start
  autocmd!
  autocmd VimEnter * call SmartTerminalStart()
augroup END

augroup close_all_windows
  autocmd!
  " バッファを閉じる前に他のウィンドウも:qで閉じる
  autocmd QuitPre * call CloseAllWindowsWithQ()
augroup END

augroup close_all_windows
  autocmd!
  " バッファを閉じる前に状況に応じて処理を分ける
  autocmd QuitPre * call SmartCloseWindows()
augroup END

function! SmartCloseWindows()
  " 現在のウィンドウの情報を取得
  let current_buf = bufname('%')
  
  " メインの編集ウィンドウから:q/:wqが実行された場合のみ全て閉じる
  if current_buf !~ 'term://' && current_buf !~ 'NERD_tree'
    " NERDTreeが開いていれば:qで閉じる
    if exists('g:NERDTree') && g:NERDTree.IsOpen()
      let nerdtree_win = g:NERDTree.GetWinNum()
      execute nerdtree_win . 'wincmd w'
      execute 'q'
      wincmd p
    endif
    
    " ターミナルウィンドウを探して:qで閉じる
    for win in range(1, winnr('$'))
      let buf = winbufnr(win)
      let bufname = bufname(buf)
      if bufname =~ 'term://'
        execute win . 'wincmd w'
        execute 'q'
        wincmd p
      endif
    endfor
  endif
endfunction
