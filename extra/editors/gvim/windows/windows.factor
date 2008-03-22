USING: editors.gvim.backend io.files io.windows kernel namespaces
sequences windows.shell32 io.paths ;
IN: editors.gvim.windows

M: windows-io gvim-path
    \ gvim-path get-global [
        program-files "vim" append-path
        t [ "gvim.exe" tail? ] find-file
    ] unless* ;
