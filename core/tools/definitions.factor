! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: arrays errors generic assocs io kernel math
namespaces parser prettyprint prettyprint-internals sequences
styles words help inspector ;

: reload ( defspec -- )
    where first [ run-file ] when* ;

: comment. ( string -- )
    [ H{ { font-style italic } } styled-text ] when* ;

: word-synopsis ( word name -- )
    dup word-vocabulary pprinter-in set
    over definer drop pprint-word
    pprint-word
    dup parsing? not swap stack-effect and
    [ effect>string comment. ] when* ;

M: word synopsis*
    dup word-synopsis ;

M: constructor synopsis*
    dup "constructing" word-prop word-synopsis ;

M: method-spec synopsis*
    dup definer drop pprint-word
    [ pprint-word ] each ;

M: pathname synopsis* pprint* ;

: synopsis ( defspec -- str )
    [
        0 margin set
        1 line-limit set
        [ synopsis* ] with-in
    ] string-out ;

M: word summary synopsis ;

GENERIC: declarations. ( obj -- )

M: object declarations. drop ;

: declaration. ( word prop -- )
    tuck word-name word-prop [ pprint-word ] [ drop ] if ;

M: word declarations.
    {
        POSTPONE: parsing
        POSTPONE: delimiter
        POSTPONE: inline
        POSTPONE: foldable
    } [ declaration. ] each-with ;

: pprint-; \ ; pprint-word ;

: (see) ( spec -- )
    [
        <colon dup synopsis*
        <block dup definition pprint-elements block>
        dup definer nip [ pprint-word ] when* declarations.
        block>
    ] with-use nl ;

M: object see (see) ;

GENERIC: see-class* ( word -- )

M: union-class see-class*
    \ UNION: pprint-word
    dup pprint-word
    members pprint-elements pprint-; ;

M: predicate-class see-class*
    \ PREDICATE: pprint-word
    dup superclass pprint-word
    dup pprint-word
    <colon
    "definition" word-prop pprint-elements
    pprint-; block> ;

M: tuple-class see-class*
    \ TUPLE: pprint-word
    dup pprint-word
    "slot-names" word-prop [ text ] each
    pprint-; ;

M: word see-class* drop ;

M: builtin-class see-class*
    drop "! Built-in class" comment. ;

: see-all ( seq -- ) [ nl see ] each ;

: see-constructor ( class -- )
    "constructor" word-prop [ nl see ] when* ;

: see-implementors ( class -- )
    dup implementors natural-sort [ 2array ] map-with see-all ;

: see-class ( class -- )
    dup class? [
        nl
        [ dup see-class* ] with-pprint nl
        dup see-constructor
        see-implementors
    ] [
        drop
    ] if ;

: see-methods ( generic -- )
    dup "methods" word-prop keys natural-sort
    [ swap 2array ] map-with see-all ;

M: word see
    dup (see)
    dup see-class
    dup generic? [ see-methods ] [ drop ] if ;

M: link where link-name article article-loc ;

M: link synopsis*
    \ ARTICLE: pprint-word
    dup link-name pprint*
    article-title pprint* ;

M: link definition article-content ;

M: link see (see) ;

PREDICATE: link word-link link-name word? ;

M: word-link where link-name "help-loc" word-prop ;

M: word-link synopsis*
    \ HELP: pprint-word
    link-name dup pprint-word
    stack-effect effect>string comment. ;

M: word-link definition link-name "help" word-prop ;

M: link forget link-name remove-article ;

M: word-link forget f "help" set-word-prop ;
