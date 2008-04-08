USING: editors.gvim.backend io.files io.windows kernel namespaces
sequences windows.shell32 io.paths system ;
IN: editors.gvim.windows

M: windows gvim-path
    \ gvim-path get-global [
        program-files "vim" append-path
        t [ "gvim.exe" tail? ] find-file
    ] unless* ;
