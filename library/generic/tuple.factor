! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays definitions errors hashtables kernel
kernel-internals math namespaces parser sequences
sequences-internals strings vectors words ;

IN: kernel-internals

: tuple= ( tuple tuple -- ? )
    2dup [ array-capacity ] 2apply number= [
        dup array-capacity
        [ 2dup swap array-nth >r pick array-nth r> = ] all? 2nip
    ] [
        2drop f
    ] if ;

IN: generic

: class ( object -- class )
    dup tuple? [ 2 slot ] [ type type>class ] if ; inline

: tuple-predicate ( word -- )
    dup predicate-word [
        [ dup tuple? ] %
        [ [ 2 slot ] % over literalize , \ eq? , ] [ ] make ,
        [ [ drop f ] if ] %
    ] [ ] make define-predicate ;

: forget-tuple ( class -- )
    dup forget "predicate" word-prop first [ forget ] when* ;

: check-shape ( word slots -- )
    >r in get lookup dup [
        dup "tuple-size" word-prop r> length 2 + =
        [ drop ] [ forget-tuple ] if
    ] [
        r> 2drop
    ] if ;

: delegate-slots { { 3 object delegate set-delegate } } ;

: tuple-slots ( tuple slots -- )
    2dup "slot-names" set-word-prop
    2dup length 2 + "tuple-size" set-word-prop
    dupd 4 simple-slots
    2dup delegate-slots swap append "slots" set-word-prop
    define-slots ;

PREDICATE: class tuple-class "tuple-size" word-prop ;

TUPLE: check-tuple class ;
: check-tuple ( class -- class )
    dup tuple-class? [ <check-tuple> throw ] unless ;

: define-constructor ( word class def -- )
    pick reset-generic
    swap check-tuple [
        dup literalize ,
        "tuple-size" word-prop ,
        \ <tuple> , %
    ] [ ] make define-compound ;

: default-constructor ( tuple -- )
    dup create-constructor 2dup "constructor" set-word-prop
    swap dup "slots" word-prop unclip drop <reversed>
    [ [ tuck ] swap peek add ] map concat >quotation
    define-constructor ;

: define-tuple ( tuple slots -- )
    2dup check-shape
    >r create-in
    dup intern-symbol
    dup tuple-predicate
    dup \ tuple bootstrap-word "superclass" set-word-prop
    dup define-class
    dup r> tuple-slots
    default-constructor ;

M: tuple clone
    (clone) dup delegate clone over set-delegate ;

M: tuple hashcode 2 slot hashcode ;

M: tuple equal?
    over tuple? [ tuple= ] [ 2drop f ] if ;

: (delegates) ( obj -- )
    [ dup delegate (delegates) , ] when* ;

: delegates ( obj -- seq )
    [ (delegates) ] { } make ;

: is? ( obj pred -- ? )
    >r delegates r> contains? ; inline

: >tuple ( seq -- tuple )
    >vector dup first "tuple-size" word-prop over set-length
    >array array>tuple ;

! Definition protocol
M: tuple-class forget
    dup "constructor" word-prop forget forget-class ;
