USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors ;

IN: editors.textmate

: textmate-location ( file line -- )
    [ "mate -a -l " % # " " % unparse % ] "" make run-process ;

[ textmate-location ] edit-hook set-global
