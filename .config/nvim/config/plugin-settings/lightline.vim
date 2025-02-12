" AutoSave状態を返す関数
function! AutoSaveStatus()
  return exists('g:auto_save') && g:auto_save == 1 ? "\ueb4a" : ""
endfunction

" 特定のファイルタイプでlightlineを非表示にする
augroup LightlineHide
  autocmd!
  autocmd FileType nerdtree let g:lightline = {}
  autocmd FileType nerdtree set noshowmode
  autocmd TermOpen * let g:lightline = {}
  autocmd TermOpen * set noshowmode
augroup END

" Lightlineをウィンドウ下部に表示する
set laststatus=3

let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [
  \     [ 'autosave','mode', 'paste' ],
  \     [ 'gitbranch', 'readonly', 'modified' ]
  \   ],
  \   'right': [
  \     [ 'lineinfo' ],
  \     [ 'percent' ],
  \     [ 'lsp_status', 'lsp_diagnostic_info', 'fileencoding', 'fileformat', 'filetype' ],
  \   ],
  \ },
  \ 'component_function': {
  \   'filename': 'lightline#additional#get_relative_path', 
  \   'fileencoding': 'lightline#additional#get_encoding',
  \   'fileformat': 'lightline#additional#get_eol',
  \   'filetype': 'lightline#additional#get_formatted_filetype',
  \   'lineinfo': 'lightline#additional#get_formatted_lineinfo',
  \   'gitbranch': 'lightline#additional#fugitive#get_head_branch',
  \   'lsp_status': 'lightline#additional#coc#get_status',
  \   'lsp_diagnostic_info': 'lightline#additional#coc#get_diagnostic_info',
  \   'autosave': 'AutoSaveStatus',
  \ },
  \ 'separator': { 'left': "\ue0b4", 'right': "\ue0b6" },
  \ 'subseparator': { 'left': "\ue0b5", 'right': "\ue0b7" }
  \ }

" NERDTreeとTerminalバッファでステータスラインを完全に非表示にする
function! ShouldHideStatusline()
  return &filetype ==# 'nerdtree' || &buftype ==# 'terminal'
endfunction

augroup CustomStatusline
  autocmd!
  autocmd BufEnter * if ShouldHideStatusline() | set laststatus=0 | else | set laststatus=3 | endif
augroup END
