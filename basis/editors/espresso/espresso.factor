USING: editors kernel make namespaces ;

IN: editors.espresso

SINGLETON: espresso

editor-class [ espresso ] initialize

M: espresso editor-command
    drop
    [ "open" , "-a" , "espresso" , , ] { } make ;
