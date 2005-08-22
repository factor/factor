! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: generic hashtables io kernel lists namespaces sequences
styles words ;

: declaration. ( word prop -- )
    tuck word-name word-prop [ bl pprint-word ] [ drop ] ifte ;

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
    ] make-string ;

: stack-effect ( word -- string )
    dup "stack-effect" word-prop [ ] [
        "infer-effect" word-prop
        dup [ effect>string ] when
    ] ?ifte ;

: stack-effect. ( string -- )
    [ bl "(" swap ")" append3 comment. ] when* ;

: in. ( word -- )
    <block \ IN: pprint-word bl word-vocabulary f text block;
    t newline ;

: definer. ( word -- )
    dup definer pprint-word bl
    dup pprint-word
    stack-effect stack-effect.
    f newline ;

GENERIC: (see) ( word -- )

M: word (see) definer. t newline ;

: documentation. ( word -- )
    "documentation" word-prop [
        "\n" split [ "#!" swap append comment. t newline ] each
    ] when* ;

: pprint-; \ ; pprint-word ;

: see-body ( quot word -- )
    dup definer. <block dup documentation. swap pprint-elements
    pprint-; declarations. block; ;

M: compound (see)
    dup word-def swap see-body t newline ;

: method. ( word [[ class method ]] -- )
    \ M: pprint-word bl
    unswons pprint-word bl
    swap pprint-word f newline
    <block pprint-elements pprint-;
    block; t newline ;

M: generic (see)
    <block
    dup dup "combination" word-prop
    swap see-body block; t newline
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
    \ UNION: pprint-word bl
    dup pprint-word bl
    "members" word-prop pprint-elements pprint-; t newline ;

M: complement class.
    \ COMPLEMENT: pprint-word bl
    dup pprint-word bl
    "complement" word-prop pprint-word t newline ;

M: predicate class.
    \ PREDICATE: pprint-word bl
    dup "superclass" word-prop pprint-word bl
    dup pprint-word f newline
    <block
    "definition" word-prop pprint-elements
    pprint-; block; t newline ;

M: tuple-class class.
    \ TUPLE: pprint-word bl
    dup pprint-word bl
    "slot-names" word-prop [ f text bl ] each
    pprint-; t newline ;

M: word class. drop ;

: see ( word -- )
    [ dup in. dup (see) dup class. methods. ] with-pprint ;
