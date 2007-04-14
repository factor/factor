! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel words sequences generic math namespaces
quotations assocs combinators math.bitfields inference.backend
inference.dataflow inference.state tuples.private effects
inspector hashtables ;
IN: inference.transforms

: pop-literals ( n -- rstate seq )
    dup zero? [
        drop recursive-state get { }
    ] [
        dup ensure-values
        f swap [ 2drop pop-literal ] map reverse
    ] if ;

: transform-quot ( quot n -- newquot )
    [ pop-literals [ ] each ] curry
    swap
    [ swap infer-quot ] 3compose ;

: define-transform ( word quot n -- )
    transform-quot "infer" set-word-prop ;

! Combinators
\ cond [
    cond>quot
] 1 define-transform

\ case [
    dup empty? [
        drop [ no-case ]
    ] [
        dup peek quotation? [
            dup peek swap 1 head*
        ] [
            [ no-case ] swap
        ] if case>quot
    ] if
] 1 define-transform

! Bitfields
GENERIC: (bitfield-quot) ( spec -- quot )

M: integer (bitfield-quot) ( spec -- quot )
    [ swapd shift bitor ] curry ;

M: pair (bitfield-quot) ( spec -- quot )
    first2 over word? [ >r swapd execute r> ] [ ] ?
    [ shift bitor ] append 2curry ;

: bitfield-quot ( spec -- quot )
    [ (bitfield-quot) ] map [ 0 ] add* concat ;

\ bitfield [ bitfield-quot ] 1 define-transform

\ flags [
    [ 0 , [ , \ bitor , ] each ] [ ] make
] 1 define-transform

! Tuple operations
: [get-slots] ( slots -- quot )
    [ [ 1quotation , \ keep , ] each \ drop , ] [ ] make ;

\ get-slots [ [get-slots] ] 1 define-transform

ERROR: duplicated-slots-error names ;

M: duplicated-slots-error summary
    drop "Calling set-slots with duplicate slot setters" ;

\ set-slots [
    dup all-unique?
    [ <reversed> [get-slots] ] [ duplicated-slots-error ] if
] 1 define-transform

\ construct-boa [
    dup +inlined+ depends-on
    tuple-layout [ <tuple-boa> ] curry
] 1 define-transform

\ construct-empty [
    1 ensure-values
    peek-d value? [
        pop-literal
        dup +inlined+ depends-on
        tuple-layout [ <tuple> ] curry
        swap infer-quot
    ] [
        \ construct-empty 1 1 <effect> make-call-node
    ] if
] "infer" set-word-prop
