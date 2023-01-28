USING: editors kernel make namespaces ;
IN: editors.smultron

EDITOR: smultron

M: smultron editor-command
    drop
    [ "open" , "-a" , "Smultron" , , ] { } make ;
