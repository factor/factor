USING: editors.gvim io.unix.backend kernel namespaces ;
IN: editors.gvim.unix

M: unix-io gvim-path
    \ gvim-path get-global [
        "gvim"
    ] unless* ;
