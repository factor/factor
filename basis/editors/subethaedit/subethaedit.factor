USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.subethaedit

SINGLETON: subethaedit
subethaedit editor-class set-global

M: subethaedit editor-command
    drop
    [ "open" , "-a" , "SubEthaEdit" , , ] { } make ;
