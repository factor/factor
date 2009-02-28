USING: definitions kernel parser words sequences math.parser
namespaces editors io.launcher windows.shell32 io.files
io.directories.search.windows strings unicode.case make ;
IN: editors.editpadlite

: editpadlite-path ( -- path )
    \ editpadlite-path get-global [
        "JGsoft" [ >lower "editpadlite.exe" tail? ] find-in-program-files
        [ "editpadlite.exe" ] unless*
    ] unless* ;

: editpadlite ( file line -- )
    [
        editpadlite-path , drop ,
    ] { } make run-detached drop ;

[ editpadlite ] edit-hook set-global
