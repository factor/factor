USING: arrays editors io.standard-paths kernel namespaces ;
IN: editors.wordpad

SINGLETON: wordpad

: wordpad-path ( -- path )
    \ wordpad-path get [
        { "Windows NT\\Accessories" } "wordpad.exe" find-in-applications
    ] unless* ;

M: wordpad editor-command
    drop [ wordpad-path ] dip 2array ;
