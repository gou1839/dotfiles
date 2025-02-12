" XDG Base Directory
if empty($XDG_DATA_HOME)   | let $XDG_DATA_HOME = expand('$HOME/.local/share') | endif
if empty($XDG_CONFIG_HOME) | let $XDG_CONFIG_HOME = expand('$HOME/.config') | endif
if empty($XDG_CACHE_HOME)  | let $XDG_CACHE_HOME = expand('$HOME/.cache') | endif

" neovim/vim specific settings
if has('nvim')
  let s:data_home = expand('$XDG_DATA_HOME/nvim')
  let s:config_home = expand('$XDG_CONFIG_HOME/nvim')
  let s:cache_home = expand('$XDG_CACHE_HOME/nvim')
  let $MYVIMRC = expand('$XDG_CONFIG_HOME/nvim/init.vim')
  let g:netrw_home = expand('$XDG_CONFIG_HOME/nvim')
else
  let s:data_home = expand('$XDG_DATA_HOME/vim')
  let s:config_home = expand('$XDG_CONFIG_HOME/vim')
  let s:cache_home = expand('$XDG_CACHE_HOME/vim')
  let $MYVIMRC = expand('$XDG_CONFIG_HOME/vim/vimrc')
  let g:netrw_home = expand('$XDG_CACHE_HOME/vim')
  if !isdirectory(s:data_home) | call mkdir(s:data_home, 'p', 0700) | endif
  if !isdirectory(s:config_home) | call mkdir(s:config_home, 'p', 0700) | endif
  if !isdirectory(s:cache_home) | call mkdir(s:cache_home, 'p', 0700) | endif
  set undodir=$XDG_DATA_HOME/vim/undo | call mkdir(&undodir, 'p', 0700)
  set directory=$XDG_DATA_HOME/vim/swap | call mkdir(&directory, 'p', 0700)
  set backupdir=$XDG_DATA_HOME/vim/backup | call mkdir(&backupdir, 'p', 0700)
  set viewdir=$XDG_DATA_HOME/vim/view | call mkdir(&viewdir, 'p', 0700)
  set viminfo+='1000,n$XDG_DATA_HOME/vim/viminfo
  set runtimepath=$XDG_DATA_HOME/vim,$VIMRUNTIME,$XDG_DATA_HOME/vim/after
endif

" Load configurations
runtime! config/options.vim
runtime! config/plugins.vim
runtime! config/autocmd.vim
runtime! config/colors.vim
runtime! config/functions.vim
runtime! config/plugin-settings/*.vim
runtime! config/plugin-settings/*.lua
runtime! config/keymap/*.vim

" Jetpack bootstrap
let s:jetpackfile = stdpath('data') .. '/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim'
let s:jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
if !filereadable(s:jetpackfile)
  call system(printf('curl -fsSLo %s --create-dirs %s', s:jetpackfile, s:jetpackurl))
endif

lua require'nvim-treesitter.configs'.setup{highlight={enable=true},indent={enable=true}}

