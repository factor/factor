USING: io.unix.backend kernel namespaces editors.gvim.backend
system ;
IN: editors.gvim.unix

M: unix gvim-path
    \ gvim-path get-global [
        "gvim"
    ] unless* ;
