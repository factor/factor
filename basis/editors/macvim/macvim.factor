USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;

IN: editors.macvim

: macvim-location ( file line -- )
    drop
    [ "open" , "-a" , "MacVim", , ] { } make
    try-process ;

[ macvim-location ] edit-hook set-global


