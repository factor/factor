! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser strings
words vectors ;

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

: builtin-predicate ( type# symbol -- )
    #! We call search here because we have to know if the symbol
    #! is t or f, and cannot compare type numbers or symbol
    #! identity during bootstrapping.
    dup "f" [ "syntax" ] search = [
        nip [ not ] "predicate" set-word-prop
    ] [
        dup "t" [ "syntax" ] search = [
            nip [ ] "predicate" set-word-prop
        ] [
            dup predicate-word
            [ rot [ swap type eq? ] cons define-compound ] keep
            unit "predicate" set-word-prop
        ] ifte
    ] ifte ;

: builtin-class ( symbol type# slotspec -- )
    >r 2dup builtins get set-vector-nth r>
    >r swap
    dup intern-symbol
    2dup builtin-predicate
    [ swap "builtin-type" set-word-prop ] keep
    dup builtin define-class r> define-slots ;

: builtin-type ( n -- symbol ) builtins get vector-nth ;

PREDICATE: word builtin metaclass builtin = ;
