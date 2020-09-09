USING: editors kernel make namespaces ;
IN: editors.bbedit

SINGLETON: bbedit
bbedit editor-class set-global

M: bbedit editor-command
    drop
    [ "open" , "-a" , "BBEdit" , , ] { } make ;
