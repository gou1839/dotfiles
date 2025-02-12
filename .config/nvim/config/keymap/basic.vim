" 基本的なキーマッピング
let mapleader = "\<Space>"

" インデント
inoremap <S-Tab> <C-h>

" 画面分割
nnoremap ss :split<CR><C-w>w
nnoremap sv :vsplit<CR><C-w>w

" アクティブウィンドウの移動
nnoremap sh <C-w>h
nnoremap sk <C-w>k
nnoremap sj <C-w>j
nnoremap sl <C-w>l
" ウィンドウ移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 検索
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" 編集モード(Insert mode)でCtrl+Wを押したときにNORMALモードに切り替える
inoremap <C-w> <ESC><C-w>
