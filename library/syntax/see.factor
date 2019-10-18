! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: generic hashtables io kernel lists namespaces sequences
styles words ;

: declaration. ( word prop -- )
    tuck word-name word-prop [ pprint-word ] [ drop ] ifte ;

: declarations. ( word -- )
    [
        POSTPONE: parsing
        POSTPONE: inline
        POSTPONE: foldable
        POSTPONE: flushable
    ] [ declaration. ] each-with ;

: comment. ( comment -- )
    [ [[ font-style italic ]] ] text ;

: stack-picture% ( seq -- string )
    [ word-name % " " % ] each ;

: effect>string ( effect -- string )
    [
        " " %
        dup first stack-picture%
        "-- " %
        second stack-picture%
    ] "" make ;

: stack-effect ( word -- string )
    dup "stack-effect" word-prop [ ] [
        "infer-effect" word-prop
        dup [ effect>string ] when
    ] ?ifte ;

: stack-effect. ( string -- )
    [ "(" swap ")" append3 comment. ] when* ;

: in. ( word -- )
    <block \ IN: pprint-word word-vocabulary f text block;
    newline ;

: definer. ( word -- )
    dup definer pprint-word
    dup pprint-word
    stack-effect stack-effect. ;

GENERIC: (see) ( word -- )

M: word (see) definer. newline ;

: documentation. ( word -- )
    "documentation" word-prop [
        "\n" split [ "#!" swap append comment. newline ] each
    ] when* ;

: pprint-; \ ; pprint-word ;

: see-body ( quot word -- )
    dup definer. <block dup documentation. swap pprint-elements
    pprint-; declarations. block; ;

M: compound (see)
    dup word-def swap see-body newline ;

: method. ( word [[ class method ]] -- )
    \ M: pprint-word
    unswons pprint-word
    swap pprint-word
    <block pprint-elements pprint-;
    block; newline ;

M: generic (see)
    dup dup "combination" word-prop swap see-body newline
    dup methods [ method. ] each-with ;

GENERIC: class. ( word -- )

: methods. ( class -- )
    #! List all methods implemented for this class.
    dup metaclass [
        dup implementors [
            dup in. tuck "methods" word-prop hash* method.
        ] each-with
    ] [
        drop
    ] ifte ;

M: union class.
    \ UNION: pprint-word
    dup pprint-word
    "members" word-prop pprint-elements pprint-; newline ;

M: predicate class.
    \ PREDICATE: pprint-word
    dup "superclass" word-prop pprint-word
    dup pprint-word
    <block
    "definition" word-prop pprint-elements
    pprint-; block; newline ;

M: tuple-class class.
    \ TUPLE: pprint-word
    dup pprint-word
    "slot-names" word-prop [ f text ] each
    pprint-; newline ;

M: word class. drop ;

: see ( word -- )
    [ dup in. dup (see) dup class. methods. ] with-pprint ;

: (apropos) ( substring -- seq )
    vocabs [
        words [ word-name subseq? ] subset-with
    ] map-with concat ;

: apropos ( substring -- )
    #! List all words that contain a string.
    (apropos) [
        "IN: " write dup word-vocabulary write " " write .
    ] each ;
