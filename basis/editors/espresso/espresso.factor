USING: editors kernel make namespaces ;

IN: editors.espresso

EDITOR: espresso

M: espresso editor-command
    drop
    [ "open" , "-a" , "espresso" , , ] { } make ;
