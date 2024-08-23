USING: editors kernel make ;
IN: editors.focus

SINGLETON: focus

M: focus editor-command
    ! support for open a file to a line number is an open issue
    ! https://github.com/focus-editor/focus/issues/376
    drop
    [ "open" , "-a" , "Focus" , , ] { } make ;
