! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors arrays kernel words sequences generic math
namespaces quotations assocs combinators classes.tuple
classes.tuple.private effects summary hashtables classes generic
sets definitions generic.standard slots.private continuations
stack-checker.backend stack-checker.state stack-checker.visitor
stack-checker.errors ;
IN: stack-checker.transforms

SYMBOL: +transform-quot+
SYMBOL: +transform-n+

: give-up-transform ( word -- )
    dup recursive-label
    [ call-recursive-word ]
    [ dup infer-word apply-word/effect ]
    if ;

: ((apply-transform)) ( word quot values stack -- )
    rot with-datastack first2
    dup [
        [
            [ drop ] [
                [ length meta-d get '[ , pop* ] times ]
                [ #drop, ]
                bi
            ] bi*
        ] 2dip
        swap infer-quot
    ] [
        3drop give-up-transform
    ] if ; inline

: (apply-transform) ( word quot n -- )
    ensure-d dup [ known literal? ] all? [
        dup empty? [
            recursive-state get 1array
        ] [
            [ ]
            [ [ literal value>> ] map ]
            [ first literal recursion>> ] tri
            prefix
        ] if
        ((apply-transform))
    ] [ 2drop give-up-transform ] if ;

: apply-transform ( word -- )
    [ inlined-dependency depends-on ] [
        [ ]
        [ +transform-quot+ word-prop ]
        [ +transform-n+ word-prop ]
        tri
        (apply-transform)
    ] bi ;

: apply-macro ( word -- )
    [ inlined-dependency depends-on ] [
        [ ]
        [ "macro" word-prop ]
        [ "declared-effect" word-prop in>> length ]
        tri
        (apply-transform)
    ] bi ;

: define-transform ( word quot n -- )
    [ drop +transform-quot+ set-word-prop ]
    [ nip +transform-n+ set-word-prop ]
    3bi ;

! Combinators
\ cond [ cond>quot ] 1 define-transform

\ case [
    dup empty? [
        drop [ no-case ]
    ] [
        dup peek quotation? [
            dup peek swap but-last
        ] [
            [ no-case ] swap
        ] if case>quot
    ] if
] 1 define-transform

\ cleave [ cleave>quot ] 1 define-transform

\ 2cleave [ 2cleave>quot ] 1 define-transform

\ 3cleave [ 3cleave>quot ] 1 define-transform

\ spread [ spread>quot ] 1 define-transform

\ (call-next-method) [
    [ [ inlined-dependency depends-on ] bi@ ] [ next-method-quot ] 2bi
] 2 define-transform

! Constructors
\ boa [
    dup tuple-class? [
        dup inlined-dependency depends-on
        [ "boa-check" word-prop ]
        [ tuple-layout '[ , <tuple-boa> ] ]
        bi append
    ] [ drop f ] if
] 1 define-transform

\ new [
    dup tuple-class? [
        dup inlined-dependency depends-on
        dup all-slots rest-slice ! delegate slot
        [ [ initial>> literalize , ] each literalize , \ boa , ] [ ] make
    ] [ drop f ] if
] 1 define-transform

! Membership testing
: bit-member-n 256 ; inline

: bit-member? ( seq -- ? )
    #! Can we use a fast byte array test here?
    {
        { [ dup length 8 < ] [ f ] }
        { [ dup [ integer? not ] contains? ] [ f ] }
        { [ dup [ 0 < ] contains? ] [ f ] }
        { [ dup [ bit-member-n >= ] contains? ] [ f ] }
        [ t ]
    } cond nip ;

: bit-member-seq ( seq -- flags )
    bit-member-n swap [ member? 1 0 ? ] curry B{ } map-as ;

: exact-float? ( f -- ? )
    dup float? [ dup >integer >float = ] [ drop f ] if ; inline

: bit-member-quot ( seq -- newquot )
    [
        bit-member-seq ,
        [
            {
                { [ over fixnum? ] [ ?nth 1 eq? ] }
                { [ over bignum? ] [ ?nth 1 eq? ] }
                { [ over exact-float? ] [ ?nth 1 eq? ] }
                [ 2drop f ]
            } cond
        ] %
    ] [ ] make ;

: member-quot ( seq -- newquot )
    dup bit-member? [
        bit-member-quot
    ] [
        [ literalize [ t ] ] { } map>assoc
        [ drop f ] suffix [ case ] curry
    ] if ;

\ member? [
    dup sequence? [ member-quot ] [ drop f ] if
] 1 define-transform

: memq-quot ( seq -- newquot )
    [ [ dupd eq? ] curry [ drop t ] ] { } map>assoc
    [ drop f ] suffix [ cond ] curry ;

\ memq? [
    dup sequence? [ memq-quot ] [ drop f ] if
] 1 define-transform
