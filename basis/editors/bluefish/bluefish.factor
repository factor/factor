USING: editors kernel make namespaces ;
IN: editors.bluefish

EDITOR: bluefish

M: bluefish editor-command
    drop
    [ "open" , "-a" , "Bluefish" , , ] { } make ;
