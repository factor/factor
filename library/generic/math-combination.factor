! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays errors generic hashtables kernel kernel-internals
math namespaces sequences words ;

PREDICATE: class math-class ( object -- ? )
    dup null bootstrap-word eq? [
        drop f
    ] [
        number bootstrap-word class<
    ] if ;

: math-class-compare ( class class -- n )
    [
        dup math-class?
        [ types last/first ] [ drop { 100 100 } ] if
    ] 2apply <=> ;

: math-class-max ( class class -- class )
    [ math-class-compare 0 > ] 2keep ? ;

: (math-upgrade) ( max class -- quot )
    dupd = [
        drop [ ]
    ] [
        "coercer" word-prop [ [ ] ] unless*
    ] if ;

: math-upgrade ( class1 class2 -- quot )
    [ math-class-max ] 2keep
    >r over r> (math-upgrade)
    >r (math-upgrade) dup empty? [ 1 make-dip ] unless
    r> append ;

TUPLE: no-math-method left right generic ;

: no-math-method ( left right generic -- * )
    <no-math-method> throw ;

: applicable-method ( generic class -- quot )
    over method [ ] [ [ no-math-method ] curry ] ?if ;

: object-method ( generic -- quot )
    object bootstrap-word applicable-method ;

: math-method ( word class1 class2 -- quot )
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
