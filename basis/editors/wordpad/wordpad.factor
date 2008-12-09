USING: editors io.launcher kernel io.paths.windows
math.parser namespaces sequences io.files arrays ;
IN: editors.wordpad

: wordpad-path ( -- path )
    \ wordpad-path get [
        "Windows NT\\Accessories" t
        [ "wordpad.exe" tail? ] find-in-program-files
    ] unless* ;

: wordpad ( file line -- )
    drop wordpad-path swap 2array run-detached drop ;

[ wordpad ] edit-hook set-global
