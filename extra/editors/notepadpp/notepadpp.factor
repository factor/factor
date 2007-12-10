USING: editors io.files io.launcher kernel math.parser
namespaces windows.shell32 ;
IN: editors.notepadpp

: notepadpp-path
    \ notepadpp-path get-global [
        program-files "notepad++\\notepad++.exe" path+
    ] unless* ;

: notepadpp ( file line -- )
    [
        notepadpp-path % " -n" % # " " % %
    ] "" make run-detached ;

[ notepadpp ] edit-hook set-global
