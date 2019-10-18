USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.textedit

: textedit ( file line -- )
    drop
    [ "open" , "-a" , "TextEdit", , ] { } make
    run-detached drop ;

[ textedit ] edit-hook set-global
