USING: editors kernel make namespaces ;
IN: editors.nova

SINGLETON: nova

M: nova editor-command
    drop
    [ "open" , "-a" , "Nova" , , ] { } make ;
