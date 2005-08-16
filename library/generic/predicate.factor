! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser
sequences strings words vectors ;

! Predicate metaclass for generalized predicate dispatch.
SYMBOL: predicate

predicate [
    over metaclass over metaclass eq? [
        >r "superclass" word-prop r> class<
    ] [
        2drop f
    ] ifte
] "class<" set-word-prop

: define-predicate-class ( class predicate definition -- )
    3dup nip "definition" set-word-prop
    pick predicate "metaclass" set-word-prop
    pick "superclass" word-prop "predicate" word-prop
    [ \ dup , % , [ drop f ] , \ ifte , ] make-list
    define-predicate ;

PREDICATE: word predicate metaclass predicate = ;
