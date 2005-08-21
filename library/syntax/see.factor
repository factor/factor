! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: generic io kernel lists namespaces sequences styles words ;

: declaration. ( word prop -- )
    tuck word-name word-prop
    [ bl pprint-object ] [ drop ] ifte ;

: declarations. ( word -- )
    [
        POSTPONE: parsing
        POSTPONE: inline
        POSTPONE: foldable
        POSTPONE: flushable
    ] [ declaration. ] each-with ;

: comment. ( comment -- )
    [ [[ font-style italic ]] ] text ;

: stack-picture ( seq -- string )
    [ [ word-name % " " % ] each ] make-string ;

: effect>string ( effect -- string )
    2unseq stack-picture >r stack-picture "-- " r> append3 ;

: stack-effect ( word -- string )
    dup "stack-effect" word-prop [ ] [
        "infer-effect" word-prop
        dup [ effect>string ] when
    ] ?ifte ;

: stack-effect. ( string -- )
    [ bl "( " swap ")" append3 comment. ] when* ;

: in. ( word -- )
    <block \ IN: pprint-object bl word-vocabulary f text block>
    t newline ;

: definer. ( word -- )
    dup definer pprint-object bl
    dup pprint-object
    stack-effect stack-effect.
    f newline ;

GENERIC: (see) ( word -- )

M: word (see) definer. t newline ;

: documentation. ( word -- )
    "documentation" word-prop [
        "\n" split [ "#!" swap append comment. t newline ] each
    ] when* ;

: see-body ( quot word -- )
    dup definer. <block dup documentation. swap pprint-elements
    \ ; pprint-object declarations. block> ;

M: compound (see)
    dup word-def swap see-body t newline ;

: method. ( word [[ class method ]] -- )
    <block
    \ M: pprint-object bl
    unswons pprint-object bl
    swap pprint-object t newline
    pprint-elements \ ; pprint-object
    block> t newline ;

M: generic (see)
    <block
    dup dup { "picker" "combination" } [ word-prop ] map-with
    swap see-body block> t newline
    dup methods [ method. ] each-with ;

: see ( word -- )
    [ dup in. (see) ] with-pprint ;
