USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;

IN: editors.macvim

: macvim ( file line -- )
    drop
    [ "open" , "-a" , "MacVim", , ] { } make
    run-detached drop ;

[ macvim ] edit-hook set-global
