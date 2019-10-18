! Generate a new factor.vim file for syntax highlighting
REQUIRES: apps/http-server ;

IN: vim

USING: embedded io ;

"libs/vim/factor.vim.fgen" resource-path
"libs/vim/factor.vim" resource-path
embedded-convert
