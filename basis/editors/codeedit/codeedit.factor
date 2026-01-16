USING: editors kernel make ;
IN: editors.codeedit

SINGLETON: codeedit

M: codeedit editor-command
    drop
    [ "open" , "-a" , "CodeEdit" , , ] { } make ;
