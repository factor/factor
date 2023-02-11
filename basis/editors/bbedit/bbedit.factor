USING: editors kernel make namespaces ;
IN: editors.bbedit

SINGLETON: bbedit

M: bbedit editor-command
    drop
    [ "open" , "-a" , "BBEdit" , , ] { } make ;
