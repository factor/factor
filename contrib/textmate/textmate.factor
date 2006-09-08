REQUIRES: contrib/embedded contrib/process ;

USING: definitions embedded io kernel parser prettyprint process
sequences namespaces ;

IN: textmate

: textmate-location ( file line -- )
    [ "mate -a \"" % over % "\" -l " % # ] "" make system drop ;

[ textmate-location ] edit-hook set-global