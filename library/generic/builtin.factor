! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser strings
words vectors ;

! Builtin metaclass for builtin types: fixnum, word, cons, etc.
SYMBOL: builtin

builtin [
    "builtin-type" word-property unit
] "builtin-supertypes" set-word-property

builtin [
    ( generic vtable definition class -- )
    rot set-vtable drop
] "add-method" set-word-property

builtin 50 "priority" set-word-property

! All builtin types are equivalent in ordering
builtin [ 2drop t ] "class<" set-word-property

: builtin-predicate ( type# symbol -- )
    #! We call search here because we have to know if the symbol
    #! is t or f, and cannot compare type numbers or symbol
    #! identity during bootstrapping.
    dup "f" [ "syntax" ] search = [
        nip [ not ] "predicate" set-word-property
    ] [
        dup "t" [ "syntax" ] search = [
            nip [ ] "predicate" set-word-property
        ] [
            dup predicate-word
            [ rot [ swap type eq? ] cons define-compound ] keep
            unit "predicate" set-word-property
        ] ifte
    ] ifte ;

: builtin-class ( symbol type# slotspec -- )
    >r swap
    dup intern-symbol
    2dup builtin-predicate
    [ swap "builtin-type" set-word-property ] keep
    dup builtin define-class r> define-slots ;

: builtin-type ( n -- symbol )
    unit classes get hash ;
