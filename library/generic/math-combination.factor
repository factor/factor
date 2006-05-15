! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: arrays errors generic hashtables kernel kernel-internals
math namespaces sequences words ;

! Math combination for generic dyadic upgrading arithmetic.

: last/first ( seq -- pair ) dup peek swap first 2array ;

: math-class? ( object -- ? )
    dup word? [ number bootstrap-word class< ] [ drop f ] if ;

: math-class-compare ( class class -- n )
    [
        dup math-class?
        [ types last/first ] [ drop { 100 100 } ] if
    ] 2apply <=> ;

: math-class-max ( class class -- class )
    [ math-class-compare 0 > ] 2keep ? ;

: (math-upgrade) ( max class -- quot )
    dupd = [ drop [ ] ] [ "coercer" word-prop ] if ;

: math-upgrade ( left right -- quot )
    [ math-class-max ] 2keep
    >r over r> (math-upgrade)
    >r (math-upgrade) dup [ 1 make-dip ] when r> append ;

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

: math-vtable* ( picker max quot -- quot )
    [
        rot , \ tag ,
        [ >r [ type>class ] map r> map % ] { } make ,
        \ dispatch ,
    ] [ ] make ; inline

: math-vtable ( picker quot -- quot )
    num-tags swap math-vtable* ; inline

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
