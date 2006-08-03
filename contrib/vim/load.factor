#! To generate factor.vim:
#! ./f factor.image
#! "contrib/httpd/embedded.factor" run-file
#! "contrib/vim/load.factor" run-file

REQUIRES: embedded ;

USING: embedded io ;


! Generate vim syntax highlighting rules
"contrib/vim" cd
"factor.vim.fgen" "factor.vim" embedded-convert


! vim word, similar to the jedit word
PROVIDE: vim {
    "vim.factor"
} ;

