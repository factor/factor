! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists math namespaces parser
sequences strings vectors words ;

! Builtin metaclass for builtin types: fixnum, word, cons, etc.
SYMBOL: builtin

! Global vector mapping type numbers to builtin class objects.
SYMBOL: builtins

: builtin-predicate ( class predicate -- )
    [ \ type , over types first , \ eq? , ] make-list
    define-predicate ;

: register-builtin ( class -- )
    dup types first builtins get set-nth ;

: define-builtin ( symbol type# predicate slotspec -- )
    >r >r >r
    dup intern-symbol
    dup r> 1vector "types" set-word-prop
    dup builtin define-class
    dup r> builtin-predicate
    dup r> intern-slots 2dup "slots" set-word-prop
    define-slots
    register-builtin ;

: type>class ( n -- symbol ) builtins get nth ;

PREDICATE: word builtin metaclass builtin = ;

: type-tag ( type -- tag )
    #! Given a type number, return the tag number.
    dup 6 > [ drop 3 ] when ;
