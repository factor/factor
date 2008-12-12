USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.textedit

: textedit-location ( file line -- )
    drop
    [ "open" , "-a" , "TextEdit", , ] { } make
    try-process ;

[ textedit-location ] edit-hook set-global
