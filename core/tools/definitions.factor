! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: arrays errors generic hashtables io kernel math
namespaces parser prettyprint prettyprint-internals sequences
styles words help ;

: reload ( defspec -- )
    where first [ run-file ] when* ;

TUPLE: no-edit-hook ;

SYMBOL: edit-hook

: edit-location ( file line -- )
    >r ?resource-path r>
    edit-hook get [ call ] [ <no-edit-hook> throw ] if* ;

: edit-file ( file -- ) ?resource-path 0 edit-location ;

: edit ( defspec -- )
    where [
        first2 edit-location
    ] [
        "Not from a source file" throw
    ] if* ;

: write-vocab ( vocab -- )
    dup <vocab-link> presented associate styled-text ;

: in. ( word -- )
    word-vocabulary [
        H{ } clone <flow \ IN: pprint-word write-vocab block>
    ] when* ;

: comment. ( string -- )
    [ H{ { font-style italic } } styled-text ] when* ;

M: word synopsis*
    dup in.
    dup definer pprint-word
    dup pprint-word
    stack-effect [ effect>string comment. ] when* ;

M: method-spec synopsis*
    \ M: pprint-word [ pprint-word ] each ;

: synopsis ( defspec -- str )
    [ 0 margin set [ synopsis* ] with-pprint ] string-out ;

M: word summary synopsis ;

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
        dup synopsis*
        dup definition [
            H{ } <defblock
            pprint-elements pprint-; declarations.
            block>
        ] [
            2drop
        ] if newline
    ] with-pprint ;

M: object see (see) ;

GENERIC: see-class* ( word -- )

M: union see-class*
    \ UNION: pprint-word
    dup pprint-word
    members pprint-elements pprint-; ;

M: predicate see-class*
    \ PREDICATE: pprint-word
    dup superclass pprint-word
    dup pprint-word
    H{ } <defblock
    "definition" word-prop pprint-elements
    pprint-; block> ;

M: tuple-class see-class*
    \ TUPLE: pprint-word
    dup pprint-word
    "slot-names" word-prop [ text ] each
    pprint-; ;

M: word see-class* drop ;

: see-class ( word -- )
    dup class? over builtin? not and [
        terpri [ see-class* ] with-pprint terpri
    ] [
        drop
    ] if ;

: see-subdefs ( word -- ) subdefs [ terpri see ] each ;

M: word see dup (see) dup see-class see-subdefs ;

M: link where link-name article article-loc ;

M: link synopsis*
    \ ARTICLE: pprint-word
    dup link-name pprint*
    article-title pprint* ;

M: link definition article-content t ;

M: link see (see) ;

PREDICATE: link word-link link-name word? ;

M: word-link where link-name "help-loc" word-prop ;

M: word-link synopsis*
    \ HELP: pprint-word
    link-name dup pprint-word
    stack-effect effect>string comment. ;

M: word-link definition
    link-name "help" word-prop t ;

M: link forget link-name remove-article ;

M: word-link forget f "help" set-word-prop ;
