USING: definitions kernel parser words sequences math.parser
namespaces editors io.launcher windows.shell32 io.files
io.directories.search.windows strings unicode.case make ;
IN: editors.editpadpro

: editpadpro-path ( -- path )
    \ editpadpro-path get-global [
        "JGsoft" [ >lower "editpadpro.exe" tail? ] find-in-program-files
        [ "editpadpro.exe" ] unless*
    ] unless* ;

: editpadpro ( file line -- )
    [
        editpadpro-path , number>string "/l" prepend , ,
    ] { } make run-detached drop ;

[ editpadpro ] edit-hook set-global
