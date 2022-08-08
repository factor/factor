USING: editors kernel make namespaces ;
IN: editors.bbedit

SINGLETON: bbedit

editor-class [ bbedit ] initialize

M: bbedit editor-command
    drop
    [ "open" , "-a" , "BBEdit" , , ] { } make ;
