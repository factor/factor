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
    >r >r dup f r> predicate-class define-class r>
    dupd "predicate-definition" set-word-prop
    dup predicate-quot define-predicate ;

M: predicate-class reset-class
    {
        "metaclass" "predicate-definition" "superclass"
    } reset-props ;
