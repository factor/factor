! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables kernel kernel.private
math namespaces sequences words quotations layouts combinators
combinators.private classes definitions ;
IN: generic.math

PREDICATE: class math-class ( object -- ? )
    dup null bootstrap-word eq? [
        drop f
    ] [
        number bootstrap-word class<
    ] if ;

: last/first ( seq -- pair ) dup peek swap first 2array ;

: math-precedence ( class -- n )
    {
        { [ dup class-empty? ] [ drop { -1 -1 } ] }
        { [ dup math-class? ] [ types last/first ] }
        { [ t ] [ drop { 100 100 } ] }
    } cond ;
    
: math-class-max ( class class -- class )
    [ [ math-precedence ] compare 0 > ] most ;

: (math-upgrade) ( max class -- quot )
    dupd = [ drop [ ] ] [ "coercer" word-prop [ ] or ] if ;

: math-upgrade ( class1 class2 -- quot )
    [ math-class-max ] 2keep
    >r over r> (math-upgrade) >r (math-upgrade)
    dup empty? [ [ dip ] curry [ ] like ] unless
    r> append ;

TUPLE: no-math-method left right generic ;

: no-math-method ( left right generic -- * )
    \ no-math-method construct-boa throw ;

: applicable-method ( generic class -- quot )
    over method method-def
    [ ] [ [ no-math-method ] curry [ ] like ] ?if ;

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
    num-tags get swap math-vtable* ; inline

TUPLE: math-combination ;

M: math-combination perform-combination
    drop
    \ over [
        dup math-class? [
            \ dup [ >r 2dup r> math-method ] math-vtable
        ] [
            over object-method
        ] if nip
    ] math-vtable nip ;

PREDICATE: generic math-generic ( word -- ? )
    "combination" word-prop math-combination? ;

M: math-generic definer drop \ MATH: f ;
