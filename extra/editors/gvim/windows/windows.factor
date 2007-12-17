USING: editors.gvim io.files io.windows kernel namespaces
sequences windows.shell32 ;
IN: editors.gvim.windows

M: windows-io gvim-path
    \ gvim-path get-global [
        program-files walk-dir [ "gvim.exe" tail? ] find nip
    ] unless* ;
