! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors fry kernel make math.parser namespaces system ;
IN: editors.geany

SINGLETON: geany
geany editor-class set-global

HOOK: geany-path os ( -- path )

M: unix geany-path
    \ geany-path get-global [ "geany" ] unless* ;

M: geany editor-command
    '[
        geany-path ,
        _ ,
        "--line" , _ number>string ,
    ] { } make ;