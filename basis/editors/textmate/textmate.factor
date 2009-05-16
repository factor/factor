USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.textmate

: textmate ( file line -- )
    [ "mate" , "-a" , "-l" , number>string , , ] { } make
    run-detached drop ;

[ textmate ] edit-hook set-global
