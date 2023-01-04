USING: editors kernel make namespaces ;
IN: editors.lite-xl

SINGLETON: lite-xl

editor-class [ lite-xl ] initialize

M: lite-xl editor-command
    drop
    [ "open" , "-a" , "Lite XL" , , ] { } make ;
