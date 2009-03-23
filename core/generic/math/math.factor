! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables kernel kernel.private math
namespaces make sequences words quotations layouts combinators
sequences.private classes classes.builtin classes.algebra
definitions math.order math.private ;
IN: generic.math

PREDICATE: math-class < class
    dup null bootstrap-word eq? [
        drop f
    ] [
        number bootstrap-word class<=
    ] if ;

: last/first ( seq -- pair ) [ peek ] [ first ] bi 2array ;

: math-precedence ( class -- pair )
    {
        { [ dup null class<= ] [ drop { -1 -1 } ] }
        { [ dup math-class? ] [ class-types last/first ] }
        [ drop { 100 100 } ]
    } cond ;
    
: math-class<=> ( class1 class2 -- class )
    [ math-precedence ] compare +gt+ eq? ;

: math-class-max ( class1 class2 -- class )
    [ math-class<=> ] most ;

: (math-upgrade) ( max class -- quot )
    dupd = [ drop [ ] ] [ "coercer" word-prop [ ] or ] if ;

: math-upgrade ( class1 class2 -- quot )
    [ math-class-max ] 2keep
    [
        (math-upgrade)
        dup empty? [ [ dip ] curry [ ] like ] unless
    ] [ (math-upgrade) ]
    bi-curry* bi append ;

ERROR: no-math-method left right generic ;

: default-math-method ( generic -- quot )
    [ no-math-method ] curry [ ] like ;

: applicable-method ( generic class -- quot )
    over method
    [ 1quotation ]
    [ default-math-method ] ?if ;

: object-method ( generic -- quot )
    object bootstrap-word applicable-method ;

: math-method ( word class1 class2 -- quot )
    2dup and [
        [
            2dup 2array , \ declare ,
            2dup math-upgrade %
            math-class-max over order min-class applicable-method %
        ] [ ] make
    ] [
        2drop object-method
    ] if ;

SYMBOL: picker

: math-vtable ( picker quot -- quot )
    [
        [ , \ tag , ]
        [ num-tags get swap [ bootstrap-type>class ] prepose map , ] bi*
        \ dispatch ,
    ] [ ] make ; inline

SINGLETON: math-combination

M: math-combination make-default-method
    drop default-math-method ;

M: math-combination perform-combination
    drop
    dup
    [
        [ 2dup both-fixnums? ] %
        dup fixnum bootstrap-word dup math-method ,
        \ over [
            dup math-class? [
                \ dup [ [ 2dup ] dip math-method ] math-vtable
            ] [
                over object-method
            ] if nip
        ] math-vtable nip ,
        \ if ,
    ] [ ] make define ;

PREDICATE: math-generic < generic ( word -- ? )
    "combination" word-prop math-combination? ;

M: math-generic definer drop \ MATH: f ;
