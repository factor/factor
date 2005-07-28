! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists math namespaces parser
sequences strings vectors words ;

! Builtin metaclass for builtin types: fixnum, word, cons, etc.
SYMBOL: builtin

! Global vector mapping type numbers to builtin class objects.
SYMBOL: builtins

builtin [
    "builtin-type" word-prop unit
] "builtin-supertypes" set-word-prop

builtin [
    ( generic vtable definition class -- )
    rot set-vtable drop
] "add-method" set-word-prop

builtin 50 "priority" set-word-prop

! All builtin types are equivalent in ordering
builtin [ 2drop t ] "class<" set-word-prop

: builtin-predicate ( class predicate -- )
    2dup register-predicate
    [ \ type , swap "builtin-type" word-prop , \ eq? , ] make-list
    define-compound ;

: register-builtin ( class -- )
    dup "builtin-type" word-prop builtins get set-nth ;

: define-builtin ( symbol type# predicate slotspec -- )
    >r >r >r
    dup intern-symbol
    dup r> "builtin-type" set-word-prop
    dup builtin define-class
    dup r> builtin-predicate
    dup r> intern-slots 2dup "slots" set-word-prop
    define-slots
    register-builtin ;

: builtin-type ( n -- symbol ) builtins get nth ;

PREDICATE: word builtin metaclass builtin = ;

: type-tag ( type -- tag )
    #! Given a type number, return the tag number.
    dup 6 > [ drop 3 ] when ;
