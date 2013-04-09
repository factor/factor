! Copyright (C) 2007 Clemens F. Hofreither.
! See http://factorcode.org/license.txt for BSD license.
! clemens.hofreither@gmx.net
USING: io.files io.launcher kernel namespaces
math math.parser editors sequences make system unicode.case
vocabs ;
IN: editors.scite

SINGLETON: scite
scite editor-class set-global

HOOK: scite-path os ( -- path )

M: unix scite-path ( -- path )
    \ scite-path get-global [ "scite" ] unless* ;

M: scite editor-command ( file line -- cmd )
    swap
    [
        scite-path ,
        ,
        number>string "-goto:" prepend ,
    ] { } make ;

os windows? [ "editors.scite.windows" require ] when
