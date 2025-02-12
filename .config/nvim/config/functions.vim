" cocのドキュメント表示設定
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" 補完トリガー
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" ターミナルを開く時に現在のファイルのディレクトリに移動する
function! TerminalOpenWithCD()
    let l:path = expand('%:p:h')
    execute 'terminal'
    call chansend(b:terminal_job_id, 'cd ' . l:path . "\<CR>")
endfunction

function! TerminalSplitWithCD()
    let l:path = expand('%:p:h')
    execute 'belowright 10new'
    execute 'terminal'
    call chansend(b:terminal_job_id, 'cd ' . l:path . "\<CR>")
endfunction
