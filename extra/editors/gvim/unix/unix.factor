USING: io.unix.backend kernel namespaces editors.gvim.backend ;
IN: editors.gvim.unix

M: unix-io gvim-path
    \ gvim-path get-global [
        "gvim"
    ] unless* ;
