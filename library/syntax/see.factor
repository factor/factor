! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: arrays generic hashtables io kernel math namespaces
sequences strings styles words ;

GENERIC: definition ( spec -- quot ? )

M: word definition drop f f ;

M: compound definition word-def t ;

M: generic definition "combination" word-prop t ;

M: method-spec definition first2 method t ;

GENERIC: see ( spec -- )

GENERIC: declarations. ( obj -- )

M: object declarations. drop ;

: declaration. ( word prop -- )
    tuck word-name word-prop [ pprint-word ] [ drop ] if ;

M: word declarations.
    {
        POSTPONE: parsing
        POSTPONE: inline
        POSTPONE: foldable
    } [ declaration. ] each-with ;

: pprint-; \ ; pprint-word ;

: (see) ( spec -- )
    [
        dup (synopsis)
        dup definition [
            H{ } <block
            pprint-elements pprint-; declarations.
            block;
        ] [
            2drop
        ] if newline
    ] with-pprint ;

M: method-spec see (see) ;

GENERIC: see-methods* ( word -- seq )

M: generic see-methods*
    dup order [ swap 2array ] map-with ;

M: class see-methods*
    dup implementors [ 2array ] map-with ;

M: word see-methods* drop f ;

: see-methods ( word -- )
    see-methods* [ see ] each ;

GENERIC: see-class* ( word -- )

M: union see-class*
    \ UNION: pprint-word
    dup pprint-word
    members pprint-elements pprint-; ;

M: predicate see-class*
    \ PREDICATE: pprint-word
    dup superclass pprint-word
    dup pprint-word
    H{ } <block
    "definition" word-prop pprint-elements
    pprint-; block; ;

M: tuple-class see-class*
    \ TUPLE: pprint-word
    dup pprint-word
    "slot-names" word-prop [ text ] each
    pprint-; ;

M: word see-class* drop ;

: see-class ( word -- )
    [
        dup class?
        [ see-class* newline ] [ drop ] if
    ] with-pprint ;

M: word see dup (see) dup see-class see-methods ;
