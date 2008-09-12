! Generate a new factor.vim file for syntax highlighting
USING: http.server.templating http.server.templating.fhtml
io.files ;
IN: editors.vim.generate-syntax

: generate-vim-syntax ( -- )
    "misc/factor.vim.fgen" resource-path <fhtml>
    "misc/factor.vim" resource-path
    template-convert ;

MAIN: generate-vim-syntax
