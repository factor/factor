USING: editors kernel make namespaces ;
IN: editors.smultron

SINGLETON: smultron

editor-class [ smultron ] initialize

M: smultron editor-command
    drop
    [ "open" , "-a" , "Smultron" , , ] { } make ;
