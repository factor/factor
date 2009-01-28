USING: definitions kernel parser words sequences math.parser
namespaces editors io.launcher windows.shell32 io.files
io.paths.windows strings unicode.case make ;
IN: editors.editpadlite

: editpadlite-path ( -- path )
    \ editpadlite-path get-global [
        "JGsoft" t [ >lower "editpadlite.exe" tail? ] find-in-program-files
    ] unless* ;

: editpadlite ( file line -- )
    [
        editpadlite-path , drop ,
    ] { } make run-detached drop ;

[ editpadlite ] edit-hook set-global
