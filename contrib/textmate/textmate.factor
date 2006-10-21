USING: definitions kernel parser process namespaces ;

IN: textmate

: textmate-location ( file line -- )
    [ "mate -a \"" % over % "\" -l " % # ] "" make run-process ;

[ textmate-location ] edit-hook set-global