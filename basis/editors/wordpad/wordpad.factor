USING: arrays editors io.standard-paths kernel namespaces ;
IN: editors.wordpad

SINGLETON: wordpad
wordpad editor-class set-global

: wordpad-path ( -- path )
    \ wordpad-path get [
        { "Windows NT\\Accessories" } "wordpad.exe" find-in-applications
    ] unless* ;

M: wordpad editor-command ( file line -- command )
    drop [ wordpad-path ] dip 2array ;
