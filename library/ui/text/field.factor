! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls generic kernel models sequences
gadgets-theme ;

TUPLE: field model ;

C: field ( model -- field )
    <editor> over set-delegate
    [ set-field-model ] keep
    dup dup set-control-self ;

: field-commit ( field -- string )
    [ editor-text ] keep
    [ field-model [ dupd set-model ] when* ] keep
    select-all ;

field {
    {
        "Editing"
        { "Clear input" T{ key-down f { C+ } "k" } [ control-model clear-doc ] }
        { "Accept input" T{ key-down f f "RETURN" } [ field-commit drop ] }
    }
} define-commands
