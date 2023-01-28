USING: editors kernel make namespaces ;

IN: editors.espresso

SINGLETON: espresso

M: espresso editor-command
    drop
    [ "open" , "-a" , "espresso" , , ] { } make ;
