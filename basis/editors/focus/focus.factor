USING: editors kernel make ;
IN: editors.focus

SINGLETON: focus

M: focus editor-command
    drop
    [ "open" , "-a" , "Focus" , , ] { } make ;
