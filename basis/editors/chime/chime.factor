USING: editors kernel make namespaces ;
IN: editors.chime

SINGLETON: chime

M: chime editor-command
    drop
    [ "open" , "-a" , "Chime" , , ] { } make ;
