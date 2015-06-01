! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit editors fry io.standard-paths
kernel make math.parser namespaces system vocabs ;
IN: editors.geany

SINGLETON: geany
geany editor-class set-global

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
