USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 make ;
IN: editors.notepad2

: notepad2-path ( -- str )
    \ notepad2-path get-global [
        program-files "C:\\Windows\\system32\\notepad.exe" append-path
   ] unless* ;

: notepad2 ( file line -- )
    [
        notepad2-path ,
        "/g" , number>string , ,
    ] { } make run-detached drop ;

[ notepad2 ] edit-hook set-global