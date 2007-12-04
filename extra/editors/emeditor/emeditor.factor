USING: editors io.launcher kernel math.parser namespaces ;
IN: editors.emeditor

: emeditor ( file line -- )
    [
        \ emeditor get-global % " /l " % #
        " " % "\"" % % "\"" %
    ] "" make run-detached ;

[ emeditor ] edit-hook set-global
