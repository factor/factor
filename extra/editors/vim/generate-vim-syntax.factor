! Generate a new factor.vim file for syntax highlighting
REQUIRES: apps/http-server ;

IN: vim

USING: embedded io ;

"extras/factor.vim.fgen" resource-path
"extras/factor.vim" resource-path
embedded-convert
