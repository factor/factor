! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors generic hashtables kernel kernel-internals lists
math namespaces sequences words ;

! Math combination for generic dyadic upgrading arithmetic.

: math-priority ( class -- n )
    dup "members" word-prop [
        0 [ math-priority max ] reduce
    ] [
        "math-priority" word-prop [ 100 ] unless*
    ] ?if ;

: math-class< ( class class -- ? )
    [ math-priority ] 2apply < ;

: math-class-max ( class class -- class )
    [ swap math-class< ] 2keep ? ;

: math-upgrade ( left right -- quot )
    2dup math-class< [
        nip "coercer" word-prop
        dup [ [ >r ] swap [ r> ] append3 ] when
    ] [
        2dup swap math-class< [
            drop "coercer" word-prop
        ] [
            2drop [ ]
        ] if
    ] if ;

TUPLE: no-math-method left right generic ;

: no-math-method ( left right generic -- )
    3dup <no-math-method> throw ;

: applicable-method ( generic class -- quot )
    over "methods" word-prop hash
    [ ] [ [ no-math-method ] curry ] ?if ;

: object-method ( generic -- quot )
    object bootstrap-word applicable-method ;

: math-method ( word left right -- quot )
    2dup and [
        2dup math-upgrade >r
        math-class-max over order min-class applicable-method
        r> swap append
    ] [
        2drop object-method
    ] if ;

: math-vtable ( picker quot -- quot )
    [
        swap , \ tag ,
        [ num-tags [ type>class ] map swap map % ] { } make ,
        \ dispatch ,
    ] [ ] make ; inline

: math-class? ( object -- ? )
    dup word? [ "math-priority" word-prop ] [ drop f ] if ;

: math-combination ( word -- quot )
    \ over [
        dup math-class? [
            \ dup [ >r 2dup r> math-method ] math-vtable
        ] [
            over object-method
        ] if nip
    ] math-vtable nip ;

PREDICATE: generic 2generic ( word -- ? )
    "combination" word-prop [ math-combination ] = ;
