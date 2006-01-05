! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: arrays generic hashtables io kernel lists math namespaces
sequences strings styles words ;

: declaration. ( word prop -- )
    tuck word-name word-prop [ pprint-word ] [ drop ] if ;

: declarations. ( word -- )
    {
        POSTPONE: parsing
        POSTPONE: inline
        POSTPONE: foldable
        POSTPONE: flushable
    } [ declaration. ] each-with ;

: in. ( word -- )
    <block \ IN: pprint-word word-vocabulary plain-text block; ;

: (synopsis) ( word -- )
    dup in. dup definer pprint-word pprint-word ;

: comment. ( comment -- )
    [ H{ { font-style italic } } text ] when* ;

: stack-picture ( seq -- string )
    dup integer? [ object <array> ] when
    [ word-name ] map " " join ;

: effect>string ( effect -- string )
    [
        "(" %
        dup first stack-picture %
        " -- " %
        second stack-picture %
        ")" %
    ] "" make ;

: stack-effect ( word -- string )
    dup "stack-effect" word-prop [ ] [
        "infer-effect" word-prop
        dup [ effect>string ] when
    ] ?if ;

: synopsis ( word -- string )
    #! Output a brief description of the word in question.
    [
        0 margin set [
            dup (synopsis) stack-effect comment.
        ] with-pprint
    ] string-out ;

GENERIC: (see) ( word -- )

M: word (see) drop ;

: pprint-; \ ; pprint-word ;

: see-body ( quot word -- )
    <block swap pprint-elements pprint-; declarations. block; ;

M: compound (see)
    dup word-def swap see-body ;

: method. ( word class method -- )
    \ M: pprint-word
    >r pprint-word pprint-word r>
    <block pprint-elements pprint-; block; ;

M: generic (see)
    dup dup "combination" word-prop swap see-body
    dup methods [ newline first2 method. ] each-with ;

GENERIC: class. ( word -- )

: methods. ( class -- )
    #! List all methods implemented for this class.
    dup class? [
        dup implementors [
            newline
            dup in. tuck dupd "methods" word-prop hash method.
        ] each-with
    ] [
        drop
    ] if ;

M: union class.
    newline
    \ UNION: pprint-word
    dup pprint-word
    members pprint-elements pprint-; ;

M: predicate class.
    newline
    \ PREDICATE: pprint-word
    dup superclass pprint-word
    dup pprint-word
    <block
    "definition" word-prop pprint-elements
    pprint-; block; ;

M: tuple-class class.
    newline
    \ TUPLE: pprint-word
    dup pprint-word
    "slot-names" word-prop [ plain-text ] each
    pprint-; ;

M: word class. drop ;

: see ( word -- )
    [
        dup (synopsis)
        dup (see)
        dup class.
        methods.
        newline
    ] with-pprint ;

: (apropos) ( substring -- seq )
    all-words [ word-name [ subseq? ] completion? ] subset-with ;

: apropos ( substring -- )
    #! List all words that contain a string.
    (apropos) word-sort
    [ [ synopsis ] keep simple-object terpri ] each ;
