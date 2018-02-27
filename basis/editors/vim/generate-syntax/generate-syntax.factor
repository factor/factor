! Generate a new factor.vim file for syntax highlighting
USING: html.templates html.templates.fhtml io.files io.pathnames ;
IN: editors.vim.generate-syntax

: generate-vim-syntax ( -- )
    "resource:misc/factor.vim.fgen" <fhtml>
    "resource:misc/vim/syntax/factor.vim"
    template-convert ;

MAIN: generate-vim-syntax
