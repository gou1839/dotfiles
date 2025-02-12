let g:jetpack_ignore_patterns = []
call add(g:jetpack_ignore_patterns, 'node_modules')
call add(g:jetpack_ignore_patterns, '/*.yaml')
let g:jetpack_copy_method='copy'
let g:jetpack#optimization=2

packadd vim-jetpack
call jetpack#begin()
Jetpack 'tani/vim-jetpack', {'opt': 1}
Jetpack 'catppuccin/nvim', { 'as': 'catppuccin' }
Jetpack 'itchyny/lightline.vim'
Jetpack 'koyashiro/lightline-additional.vim'
Jetpack 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Jetpack 'Xuyuanp/nerdtree-git-plugin'
Jetpack 'ryanoasis/vim-devicons'
Jetpack 'vim-scripts/vim-auto-save'
Jetpack 'vim-jp/vimdoc-ja'
Jetpack 'tpope/vim-surround'
Jetpack 'tpope/vim-repeat'
Jetpack 'jiangmiao/auto-pairs'
Jetpack 'tpope/vim-commentary'
Jetpack 'junegunn/fzf'
Jetpack 'junegunn/fzf.vim', { 'do': { -> fzf#install() } }
Jetpack 'coreyja/fzf.devicon.vim'
Jetpack 'editorconfig/editorconfig-vim'
Jetpack 'elzr/vim-json'
Jetpack 'tpope/vim-fugitive'
Jetpack 'airblade/vim-gitgutter'
Jetpack 'iamcco/markdown-preview.nvim'
Jetpack 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Jetpack 'neoclide/coc.nvim', {'branch': 'release'}
Jetpack 'antoinemadec/coc-fzf'
Jetpack 'nvim-tree/nvim-web-devicons' " OPTIONAL: for file icons
Jetpack 'lewis6991/gitsigns.nvim' " OPTIONAL: for git status
Jetpack 'romgrk/barbar.nvim'
Jetpack 'sourcegraph/sg.nvim', { 'do': 'nvim -l build/init.lua' }
Jetpack 'nvim-lua/plenary.nvim'
call jetpack#end()
