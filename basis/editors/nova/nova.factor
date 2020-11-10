USING: editors kernel make namespaces ;
IN: editors.nova

SINGLETON: nova
nova editor-class set-global

M: nova editor-command
    drop
    [ "open" , "-a" , "Nova" , , ] { } make ;
