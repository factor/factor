USING: editors hardware-info.windows io.launcher kernel
math.parser namespaces sequences windows.shell32 io.files
arrays ;
IN: editors.wordpad

: wordpad-path ( -- path )
    \ wordpad-path get [
        program-files "\\Windows NT\\Accessories\\wordpad.exe" path+
    ] unless* ;

: wordpad ( file line -- )
    drop wordpad-path swap 2array run-detached drop ;

[ wordpad ] edit-hook set-global
