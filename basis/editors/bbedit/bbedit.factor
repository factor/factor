USING: editors kernel make namespaces ;
IN: editors.bbedit

EDITOR: bbedit

M: bbedit editor-command
    drop
    [ "open" , "-a" , "BBEdit" , , ] { } make ;
