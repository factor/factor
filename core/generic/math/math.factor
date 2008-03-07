! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables kernel kernel.private
math namespaces sequences words quotations layouts combinators
sequences.private classes definitions ;
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

: default-math-method ( generic -- quot )
    [ no-math-method ] curry [ ] like ;

: applicable-method ( generic class -- quot )
    over method
    [ word-def ]
    [ default-math-method ] ?if ;

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

: math-vtable ( picker quot -- quot )
    [
        >r
        , \ tag ,
        num-tags get [ bootstrap-type>class ]
        r> compose map ,
        \ dispatch ,
    ] [ ] make ; inline

TUPLE: math-combination ;

M: math-combination make-default-method
    drop default-math-method ;

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
