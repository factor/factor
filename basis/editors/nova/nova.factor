USING: editors kernel make namespaces ;
IN: editors.nova

EDITOR: nova

M: nova editor-command
    drop
    [ "open" , "-a" , "Nova" , , ] { } make ;
