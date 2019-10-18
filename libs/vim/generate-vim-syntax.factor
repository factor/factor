! Generate a new factor.vim file for syntax highlighting
REQUIRES: libs/httpd ;

IN: vim

USING: embedded io ;

"libs/vim/factor.vim.fgen" resource-path
"libs/vim/factor.vim" resource-path
embedded-convert
