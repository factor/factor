USING: editors kernel make namespaces ;
IN: editors.smultron

SINGLETON: smultron
smultron editor-class set-global

M: smultron editor-command
    drop
    [ "open" , "-a" , "Smultron" , , ] { } make ;
