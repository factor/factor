USING: definitions kernel parser process namespaces prettyprint ;

IN: textmate

: textmate-location ( file line -- )
    [ "mate -a -l " % # " " % unparse % ] "" make run-process ;

[ textmate-location ] edit-hook set-global
