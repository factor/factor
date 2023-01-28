USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.textedit

EDITOR: textedit

M: textedit editor-command
    drop
    [ "open" , "-a" , "TextEdit" , , ] { } make ;
