USING: definitions kernel parser words sequences math.parser
namespaces editors io.launcher windows.shell32 io.files
io.paths strings unicode.case ;
IN: editors.editpadpro

: editpadpro-path
    \ editpadpro-path get-global [
        program-files "JGsoft" path+
        [ >lower "editpadpro.exe" tail? ] find-file-breadth
    ] unless* ;

: editpadpro ( file line -- )
    [
        editpadpro-path , "/l" swap number>string append , ,
    ] { } make run-detached drop ;

[ editpadpro ] edit-hook set-global
