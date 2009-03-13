! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.algebra kernel namespaces make words
sequences quotations arrays kernel.private assocs combinators ;
IN: classes.predicate

PREDICATE: predicate-class < class
    "metaclass" word-prop predicate-class eq? ;

DEFER: predicate-instance? ( object class -- ? )

: update-predicate-instance ( -- )
    \ predicate-instance? bootstrap-word
    classes [ predicate-class? ] filter [
        [ literalize ]
        [
            [ superclass 1array [ declare ] curry ]
            [ "predicate-definition" word-prop ]
            bi compose
        ]
        bi
    ] { } map>assoc [ case ] curry
    define ;

: predicate-quot ( class -- quot )
    [
        \ dup ,
        [ superclass "predicate" word-prop % ]
        [ "predicate-definition" word-prop , ] bi
        [ drop f ] , \ if ,
    ] [ ] make ;

: define-predicate-class ( class superclass definition -- )
    [ drop f f predicate-class define-class ]
    [ nip "predicate-definition" set-word-prop ]
    [
        2drop
        [ dup predicate-quot define-predicate ]
        [ update-classes ]
        bi
    ]
    3tri
    update-predicate-instance ;

M: predicate-class reset-class
    [ call-next-method ] [ { "predicate-definition" } reset-props ] bi
    update-predicate-instance ;

M: predicate-class rank-class drop 1 ;

M: predicate-class instance?
    2dup superclass instance?
    [ predicate-instance? ] [ 2drop f ] if ;

M: predicate-class (flatten-class)
    superclass (flatten-class) ;

M: predicate-class (classes-intersect?)
    superclass classes-intersect? ;
