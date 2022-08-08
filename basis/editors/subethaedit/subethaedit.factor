USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.subethaedit

SINGLETON: subethaedit

editor-class [ subethaedit ] initialize

M: subethaedit editor-command
    drop
    [ "open" , "-a" , "SubEthaEdit" , , ] { } make ;
