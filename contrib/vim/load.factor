REQUIRES: embedded process ;

USING: embedded io ;


! Generate vim syntax highlighting rules
"contrib/vim" cd
"factor.vim.fgen" "factor.vim" embedded-convert

! vim word, similar to the jedit word
PROVIDE: vim {
    "vim.factor"
} ;

