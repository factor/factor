! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser strings
words vectors ;

! Predicate metaclass for generalized predicate dispatch.
SYMBOL: predicate

: predicate-dispatch ( existing definition class -- dispatch )
    [
        \ dup , "predicate" word-property append, , , \ ifte ,
    ] make-list ;

: predicate-method ( vtable definition class type# -- )
    >r rot r> swap [
        vector-nth
        ( vtable definition class existing )
        -rot predicate-dispatch
    ] 2keep set-vector-nth ;

predicate [
    "superclass" word-property builtin-supertypes
] "builtin-supertypes" set-word-property

predicate [
    ( generic vtable definition class -- )
    dup builtin-supertypes [
        ( vtable definition class type# )
        >r 3dup r> predicate-method
    ] each 2drop 2drop
] "add-method" set-word-property

predicate 25 "priority" set-word-property

predicate [
    2dup = [
        2drop t
    ] [
        >r "superclass" word-property r> class<
    ] ifte
] "class<" set-word-property

: define-predicate ( class predicate definition -- )
    pick "superclass" word-property "predicate" word-property
    [ \ dup , append, , [ drop f ] , \ ifte , ] make-list
    define-compound
    predicate "metaclass" set-word-property ;
