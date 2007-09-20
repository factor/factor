USING: definitions kernel parser words sequences math.parser
namespaces editors io.launcher ;
IN: editors.editpadpro

: editpadpro ( file line -- )
    [ "editpadpro.exe /l" % # " \"" % % "\"" % ] "" make run-process ;

[ editpadpro ] edit-hook set-global
