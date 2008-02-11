! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: effects words kernel sequences slots slots.private
assocs parser mirrors namespaces math vocabs tuples ;
IN: new-slots

: create-accessor ( name effect -- word )
    >r "accessors" create dup r>
    "declared-effect" set-word-prop ;

: reader-effect T{ effect f { "object" } { "value" } } ; inline

: reader-word ( name -- word )
    ">>" append reader-effect create-accessor ;

: define-reader ( class slot name -- )
    reader-word [ slot ] define-slot-word ;

: writer-effect T{ effect f { "value" "object" } { } } ; inline

: writer-word ( name -- word )
    "(>>" swap ")" 3append writer-effect create-accessor ;

: define-writer ( class slot name -- )
    writer-word [ set-slot ] define-slot-word ;

: setter-effect T{ effect f { "object" "value" } { "value" } } ; inline

: setter-word ( name -- word )
    ">>" swap append setter-effect create-accessor ;

: define-setter ( name -- )
    dup setter-word dup deferred? [
        [ \ over , swap writer-word , ] [ ] make define-inline
    ] [ 2drop ] if ;

: changer-effect T{ effect f { "object" "quot" } } ; inline

: changer-word ( name -- word )
    "change-" swap append changer-effect create-accessor ;

: define-changer ( name -- )
    dup changer-word dup deferred? [
        [
            [ over >r >r ] %
            over reader-word ,
            [ r> call r> ] %
            swap writer-word ,
        ] [ ] make define
    ] [ 2drop ] if ;

: define-new-slot ( class slot name -- )
    dup define-changer
    dup define-setter
    3dup define-reader
    define-writer ;

: define-new-slots ( tuple-class -- )
    [ "slot-names" word-prop <enum> >alist ] keep
    [ swap first2 >r 4 + r> define-new-slot ] curry each ;

: TUPLE:
    CREATE-CLASS
    dup ";" parse-tokens define-tuple-class
    define-new-slots ; parsing

"accessors" create-vocab drop
