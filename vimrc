set number
set tabstop=2
set shiftwidth=2
set expandtab
set backspace=2
set nocompatible
syntax enable
set background=dark
let g:solarized_termtrans=1
colorscheme solarized
set clipboard=unnamed
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

" copy to buffer
vmap <C-c> :w! ~/.vimbuffer<CR>
nmap <C-c> :.w! ~/.vimbuffer<CR>
" paste from buffer
map <C-p> :r ~/.vimbuffer<CR>

