USING: editors.gvim io.files io.windows kernel namespaces
sequences windows.shell32 io.paths.windows system ;
IN: editors.gvim.windows

M: windows gvim-path
    \ gvim-path get-global [
        "vim" t [ "gvim.exe" tail? ] find-in-program-files
    ] unless* ;
