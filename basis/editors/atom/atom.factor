! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: editors kernel make math.parser namespaces sequences ;
IN: editors.atom

SINGLETON: atom-editor
atom-editor \ editor-class set-global

SYMBOL: atom-path

M: atom-editor editor-command ( file line -- command )
    [
        atom-path get "atom" or ,
        number>string ":" glue ,
    ] { } make ;

