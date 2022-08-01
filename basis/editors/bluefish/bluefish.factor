USING: editors kernel make namespaces ;
IN: editors.bluefish

SINGLETON: bluefish

editor-class [ bluefish ] initialize

M: bluefish editor-command
    drop
    [ "open" , "-a" , "Bluefish" , , ] { } make ;
