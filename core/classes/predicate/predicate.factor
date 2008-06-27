! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes kernel namespaces words ;
IN: classes.predicate

PREDICATE: predicate-class < class
    "metaclass" word-prop predicate-class eq? ;

: predicate-quot ( class -- quot )
    [
        \ dup ,
        dup superclass "predicate" word-prop %
        "predicate-definition" word-prop , [ drop f ] , \ if ,
    ] [ ] make ;

: define-predicate-class ( class superclass definition -- )
    [ drop f f predicate-class define-class ]
    [ nip "predicate-definition" set-word-prop ]
    [
        2drop
        [ dup predicate-quot define-predicate ]
        [ update-classes ]
        bi
    ] 3tri ;

M: predicate-class reset-class
    [ call-next-method ]
    [ { "predicate-definition" } reset-props ]
    bi ;

M: predicate-class rank-class drop 1 ;
