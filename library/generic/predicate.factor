! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser strings
words vectors ;

! Predicate metaclass for generalized predicate dispatch.
SYMBOL: predicate

: predicate-dispatch ( existing definition class -- dispatch )
    [
        \ dup , "predicate" word-prop append, , , \ ifte ,
    ] make-list ;

: predicate-method ( vtable definition class type# -- )
    >r rot r> swap [
        vector-nth
        ( vtable definition class existing )
        -rot predicate-dispatch
    ] 2keep set-vector-nth ;

predicate [
    "superclass" word-prop builtin-supertypes
] "builtin-supertypes" set-word-prop

predicate [
    ( generic vtable definition class -- )
    dup builtin-supertypes [
        ( vtable definition class type# )
        >r 3dup r> predicate-method
    ] each 2drop 2drop
] "add-method" set-word-prop

predicate 25 "priority" set-word-prop

predicate [
    2dup = [
        2drop t
    ] [
        >r "superclass" word-prop r> class<
    ] ifte
] "class<" set-word-prop

: define-predicate ( class predicate definition -- )
    pick over "definition" set-word-prop
    pick "superclass" word-prop "predicate" word-prop
    [ \ dup , append, , [ drop f ] , \ ifte , ] make-list
    define-compound
    predicate "metaclass" set-word-prop ;

PREDICATE: word predicate metaclass predicate = ;
