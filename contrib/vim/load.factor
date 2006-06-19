#! To generate factor.vim:
#! ./f factor.image
#! "contrib/httpd/embedded.factor" run-file
#! "contrib/vim/load.factor" run-file

REQUIRE: embedded ;

USING: embedded io ;

"contrib/vim" cd
"factor.vim.fgen" "factor.vim" embedded-convert
