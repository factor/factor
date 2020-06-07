! Generate a new factor.vim file for syntax highlighting
USING: io.encodings.utf8 io.files parser ;
IN: editors.vim.generate-syntax

: generate-vim-syntax ( -- )
    "resource:misc/vim/syntax/factor/generated.vim"
    utf8 "resource:misc/factor.vim.fgen" parse-file
    with-file-writer ;

MAIN: generate-vim-syntax
