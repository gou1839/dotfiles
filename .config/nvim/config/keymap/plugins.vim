" プラグイン関連のキーマッピング

" NERDTree
nnoremap <C-e> :NERDTreeToggle<CR>

" fzf
nnoremap <C-p> :<C-u>Files<CR>
tnoremap <expr> <Esc> (&filetype == "fzf") ? "<Esc>" : "<c-\><c-n>"

" coc.nvim
inoremap <expr> <C-n> coc#refresh()
 
inoremap <silent><expr> <Tab> pumvisible()
\ ? coc#_select_confirm()
\ : "\<Tab>"

inoremap <silent><expr> <cr> pumvisible()
\ ? coc#_select_confirm()
\ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>

nmap <leader>rn <nlug>(coc-rename)
nmap <leader>ac <Plug>(coc-codeaction)

" barbar
" バッファ間移動
nnoremap <C-j> :BufferPrevious<CR>
nnoremap <C-k> :BufferNext<CR> 
" バッファの削除
nnoremap <leader>e :BufferClose<CR>
