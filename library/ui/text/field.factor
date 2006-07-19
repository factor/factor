! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets generic kernel models ;

TUPLE: field model ;

C: field ( model -- field )
    <editor> over set-delegate
    [ set-field-model ] keep ;

: field-prev editor-document go-back ;

: field-next editor-document go-forward ;

: field-commit ( field -- string )
    [ editor-text ] keep
    dup field-model [ dupd set-model ] when*
    editor-document dup add-history clear-doc ;

field H{
    { T{ key-down f { C+ } "p" } [ field-prev ] }
    { T{ key-down f { C+ } "n" } [ field-next ] }
    { T{ key-down f { C+ } "k" } [ editor-document clear-doc ] }
    { T{ key-down f f "RETURN" } [ field-commit drop ] }
} set-gestures
