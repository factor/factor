REQUIRES: libs/process ;

USING: definitions kernel parser words sequences math process
namespaces tools ;

IN: editpadpro

: editpadpro ( file line -- )
    [ "editpadpro.exe /l" % # " \"" % % "\"" % ] "" make run-process ;

[ editpadpro ] edit-hook set-global
