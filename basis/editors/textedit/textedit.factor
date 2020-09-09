USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.textedit

SINGLETON: textedit
textedit editor-class set-global

M: textedit editor-command
    drop
    [ "open" , "-a" , "TextEdit" , , ] { } make ;
