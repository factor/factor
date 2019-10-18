! Generate a new factor.vim file for syntax highlighting
REQUIRES: contrib/httpd ;

IN: vim

USING: embedded io ;

"contrib/vim/factor.vim.fgen" resource-path
"contrib/vim/factor.vim" resource-path
embedded-convert
