USING: editors kernel make namespaces ;
IN: editors.nova

SINGLETON: nova

editor-class [ nova ] initialize

M: nova editor-command
    drop
    [ "open" , "-a" , "Nova" , , ] { } make ;
