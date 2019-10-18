REQUIRES: libs/process ;
PROVIDE: libs/vim

USING: kernel ;

{ +files+ { "vim.factor" "vim.facts" { "gvim7.factor" [ win32? ] } } }
{ +help+ { "vim" "vim" } } ;
