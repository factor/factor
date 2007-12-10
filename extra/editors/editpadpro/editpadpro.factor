USING: definitions kernel parser words sequences math.parser
namespaces editors io.launcher windows.shell32 io.files
io.paths strings ;
IN: editors.editpadpro

: editpadpro-path
    \ editpadpro-path get-global [
        program-files "JGsoft" path+ walk-dir
        [ >lower "editpadpro.exe" tail? ] find nip
    ] unless* ;

: editpadpro ( file line -- )
    [ editpadpro-path % " /l" % # " \"" % % "\"" % ] "" make run-detached ;

[ editpadpro ] edit-hook set-global
