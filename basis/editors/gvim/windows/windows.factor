USING: editors.gvim io.files kernel namespaces sequences
windows.shell32 io.directories.search.windows system
io.pathnames ;
IN: editors.gvim.windows

M: windows gvim-path
    \ gvim-path get-global [
        "vim" [ "gvim.exe" tail? ] find-in-program-files
        [ "gvim.exe" ] unless*
    ] unless* ;
