! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: words parser kernel namespaces lists strings
kernel-internals math hashtables errors ;

: make-tuple ( class -- )
    dup "tuple-size" word-property <tuple>
    [ 0 swap set-array-nth ] keep ;

: define-tuple-generic ( tuple word def -- )
    over >r \ single-combination \ GENERIC: r> define-generic
    define-method ;

: define-accessor ( word name n -- )
    >r [ >r dup word-name , "-" , r> , ] make-string
    "in" get create  r> [ slot ] cons define-tuple-generic ;

: define-mutator ( word name n -- )
    >r [ "set-" , >r dup word-name , "-" , r> , ] make-string
    "in" get create  r> [ set-slot ] cons define-tuple-generic ;

: define-field ( word name n -- )
    3dup define-accessor define-mutator ;

: tuple-predicate ( word -- )
    #! Make a foo? word for testing the tuple class at the top
    #! of the stack.
    dup predicate-word swap
    [ swap dup tuple? [ class eq? ] [ 2drop f ] ifte ] cons
    define-compound ;

: define-tuple ( word fields -- )
    2dup length 1 + "tuple-size" set-word-property
    dup length [ 3 + ] project zip
    [ uncons define-field ] each-with ;

: TUPLE:
    #! Followed by a tuple name, then field names, then ;
    CREATE
    dup intern-symbol
    dup tuple-predicate
    dup define-promise
    dup tuple "metaclass" set-word-property
    string-mode on
    [ string-mode off define-tuple ]
    f ; parsing

: constructor-word ( word -- word )
    word-name "<" swap ">" cat3 "in" get create ;

: tuple-constructor ( word def -- )
    over constructor-word >r
    [ swap literal, \ make-tuple , append, ] make-list
    r> swap define-compound ;

: TC:
    #! Followed by a tuple name, then constructor code, then ;
    #! Constructor code executes with the empty tuple on the
    #! stack.
    scan-word [ tuple-constructor ] f ; parsing

: tuple-dispatch ( object selector -- object quot )
    over class over "methods" word-property hash* dup [
        nip cdr ( method is defined )
    ] [
       ! drop delegate rot hash [
       !     swap tuple-dispatch ( check delegate )
       ! ] [
            [ undefined-method ] ( no delegate )
       ! ] ifte*
    ] ifte ;

: add-tuple-dispatch ( word vtable -- )
    >r unit [ car tuple-dispatch call ] cons tuple r>
    set-vtable ;

M: tuple class ( obj -- class ) 2 slot ;

tuple [
    ( generic vtable definition class -- )
    2drop add-tuple-dispatch
] "add-method" set-word-property

tuple [
    drop tuple "builtin-type" word-property unit
] "builtin-supertypes" set-word-property

tuple 10 "priority" set-word-property

tuple [ 2drop t ] "class<" set-word-property
