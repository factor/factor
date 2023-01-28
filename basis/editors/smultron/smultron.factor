USING: editors kernel make namespaces ;
IN: editors.smultron

SINGLETON: smultron

M: smultron editor-command
    drop
    [ "open" , "-a" , "Smultron" , , ] { } make ;
