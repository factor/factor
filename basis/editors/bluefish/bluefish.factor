USING: editors kernel make namespaces ;
IN: editors.bluefish

SINGLETON: bluefish

M: bluefish editor-command
    drop
    [ "open" , "-a" , "Bluefish" , , ] { } make ;
