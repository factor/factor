USING: kernel namespaces editors.gvim system ;
IN: editors.gvim.unix

M: unix gvim-path
    \ gvim-path get-global [
        "gvim"
    ] unless* ;
