#! To generate factor.vim:
#! ./f factor.image
#! "contrib/httpd/embedded.factor" run-file
#! "contrib/vim/load.factor" run-file

USING: embedded io ;

"contrib/vim" cd
"factor.vim.fgen" "factor.vim" embedded-convert

