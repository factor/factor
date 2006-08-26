! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: arrays errors generic hashtables io kernel math
namespaces parser prettyprint sequences styles words ;

: ?resource-path ( path -- path )
    "resource:/" ?head [ resource-path ] when ;

: where ( defspec -- loc )
    where* first2 >r ?resource-path r> 2array ;

: reload ( defspec -- )
    where first [ run-file ] when* ;

TUPLE: no-edit-hook ;

SYMBOL: edit-hook

: edit-location ( file line -- )
    edit-hook get [ call ] [ <no-edit-hook> throw ] if* ;

: edit ( defspec -- )
    where [
        first2 edit-location
    ] [
        "Not from a source file" throw
    ] if* ;

GENERIC: synopsis ( defspec -- )

: write-vocab ( vocab -- )
    dup <vocab-link> presented associate styled-text ;

: in. ( word -- )
    word-vocabulary [
        H{ } <block \ IN: pprint-word write-vocab block;
    ] when* ;

: comment. ( string -- )
    [ H{ { font-style italic } } styled-text ] when* ;

M: word synopsis
    dup in.
    dup definer pprint-word
    dup pprint-word
    stack-effect [ effect>string comment. ] when* ;

M: method-spec synopsis
    \ M: pprint-word [ pprint-word ] each ;

M: word summary ( defspec -- str )
    [ 0 margin set [ synopsis ] with-pprint ] string-out ;

GENERIC: definition ( spec -- quot ? )

M: word definition drop f f ;

M: compound definition word-def t ;

M: generic definition "combination" word-prop t ;

M: method-spec definition first2 method method-def t ;

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
        dup synopsis
        dup definition [
            H{ } <block
            pprint-elements pprint-; declarations.
            block;
        ] [
            2drop
        ] if newline
    ] with-pprint ;

M: method-spec see (see) ;

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

M: word see dup (see) dup see-class see-subdefs ;
