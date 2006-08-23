! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls generic kernel models sequences ;

TUPLE: field model history ;

C: field ( model -- field )
    <editor> over set-delegate
    V{ } clone over set-field-history
    [ set-field-model ] keep
    dup dup set-control-self ;

: field-commit ( field -- string )
    [ editor-text ] keep
    [ field-history push-new ] 2keep
    [ field-model [ dupd set-model ] when* ] keep
    select-all ;

field H{
    { T{ key-down f { C+ } "k" } [ control-model clear-doc ] }
    { T{ key-down f f "RETURN" } [ field-commit drop ] }
} set-gestures
