function! ShowKeyHelp()
  let help_text = [
        \ '基本操作',
        \ '========',
        \ '<Space>       : Leader キー',
        \ '<S-Tab>       : インデントを減らす (挿入モード)',
        \ '<Esc><Esc>    : 検索ハイライトを消去',
        \ '',
        \ 'ウィンドウ操作',
        \ '============',
        \ 'ss            : 水平分割',
        \ 'sv            : 垂直分割',
        \ 'sh            : 左のウィンドウに移動',
        \ 'sj            : 下のウィンドウに移動',
        \ 'sk            : 上のウィンドウに移動',
        \ 'sl            : 右のウィンドウに移動',
        \ '<C-h>         : 左のウィンドウに移動',
        \ '<C-j>         : 下のウィンドウに移動',
        \ '<C-k>         : 上のウィンドウに移動',
        \ '<C-l>         : 右のウィンドウに移動',
        \ '',
        \ 'プラグイン操作',
        \ '============',
        \ '<C-e>         : NERDTreeの表示切り替え',
        \ '<C-p>         : fzfでファイル検索',
        \ '<C-n>         : COC補完の更新（挿入モード）',
        \ '<Tab>         : COC補完の選択（挿入モード）',
        \ '<CR>          : COC補完の確定（挿入モード）',
        \ '[g            : 前の診断へジャンプ',
        \ ']g            : 次の診断へジャンプ',
        \ 'gd            : 定義へジャンプ',
        \ 'gy            : 型定義へジャンプ',
        \ 'gi            : 実装へジャンプ',
        \ 'gr            : 参照へジャンプ',
        \ 'K             : ドキュメントを表示',
        \ '<leader>rn    : 変数名をリネーム',
        \ '<leader>ac    : コードアクションを実行',
        \ '<C-j>         : 前のバッファに移動',
        \ '<C-k>         : 次のバッファに移動',
        \ '<leader>e     : バッファの削除',
        \ '',
        \ 'ターミナル操作',
        \ '============',
        \ 'tt            : ターミナルを水平分割で開く',
        \ '<ESC>         : ターミナルモードを終了',
        \ '',
        \ 'ターミナルモードでのウィンドウ操作',
        \ '========================',
        \ '<C-W>h/j/k/l  : ウィンドウ間を移動',
        \ '<C-W>n        : 新しいウィンドウを作成',
        \ '<C-W>q        : ウィンドウを閉じる',
        \ '<C-W>o        : 現在のウィンドウのみ表示',
        \ '<C-W>=        : ウィンドウサイズを均等に',
        \ '<C-W>+/-      : ウィンドウサイズを増減',
        \ '<C-W>H/J/K/L  : ウィンドウ位置を変更',
        \ '<C-W>r/R      : ウィンドウをローテーション',
        \ '<C-W>x        : 隣接するウィンドウと入れ替え',
        \ '<C-W>z        : プレビューウィンドウを閉じる'
        \ ]

  " 新しいバッファを作成
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:true, help_text)

  " フローティングウィンドウのオプション設定
  let win_opts = {
        \ 'relative': 'editor',
        \ 'width': 50,
        \ 'height': 20,
        \ 'row': 3,
        \ 'col': 10,
        \ 'style': 'minimal',
        \ 'border': 'rounded'
        \ }

  " フローティングウィンドウを作成
  let win = nvim_open_win(buf, v:true, win_opts)

  " バッファを編集不可に設定
  call nvim_buf_set_option(buf, 'modifiable', v:false)
  call nvim_buf_set_option(buf, 'buftype', 'nofile')

  " `q` キーで閉じるマッピングを設定
  nnoremap <buffer> q :bd!<CR>
endfunction

command! KeyHelp call ShowKeyHelp()
