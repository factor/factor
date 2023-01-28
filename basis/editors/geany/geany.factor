! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit editors io.standard-paths
kernel make math.parser namespaces system ;
IN: editors.geany

SINGLETON: geany

SYMBOL: geany-path

HOOK: find-geany-path os ( -- path )

M: unix find-geany-path "geany" ;

M: windows find-geany-path
    {
        [ { "Geany" } "geany.exe" find-in-applications ]
        [ "Geany.exe" ]
    } 0|| ;

M: geany editor-command
    '[
        geany-path get [ find-geany-path ] unless* ,
        _ ,
        "--line" , _ number>string ,
    ] { } make ;
