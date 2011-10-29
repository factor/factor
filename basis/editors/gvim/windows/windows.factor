USING: editors.gvim io.directories.search.windows sequences
system ;
IN: editors.gvim.windows

M: windows find-gvim-path
    "vim" [ "gvim.exe" tail? ] find-in-program-files ;
