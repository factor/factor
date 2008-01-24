USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors ;

IN: editors.textmate

: textmate-location ( file line -- )
    [ "mate" , "-a" , "-l" , number>string , , ] { } make
    run-process drop ;

[ textmate-location ] edit-hook set-global
