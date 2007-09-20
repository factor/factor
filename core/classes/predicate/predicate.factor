! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes kernel namespaces words ;
IN: classes.predicate

PREDICATE: class predicate-class
    "metaclass" word-prop predicate-class eq? ;

: predicate-quot ( class -- quot )
    [
        \ dup ,
        dup superclass "predicate" word-prop %
        "predicate-definition" word-prop , [ drop f ] , \ if ,
    ] [ ] make ;

: define-predicate-class ( superclass class definition -- )
    >r dup f roll predicate-class define-class r>
    dupd "predicate-definition" set-word-prop
    dup predicate-word over predicate-quot define-predicate ;

M: predicate-class reset-class
    {
        "metaclass" "predicate-definition" "superclass"
    } reset-props ;
