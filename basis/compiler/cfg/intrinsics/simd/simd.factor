! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays fry cpu.architecture kernel math
sequences math.vectors.simd.intrinsics macros generalizations
combinators combinators.short-circuit arrays
compiler.tree.propagation.info compiler.cfg.builder.blocks
compiler.cfg.stacks compiler.cfg.stacks.local compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.intrinsics.alien ;
IN: compiler.cfg.intrinsics.simd

MACRO: check-elements ( quots -- )
    [ length '[ _ firstn ] ]
    [ '[ _ spread ] ]
    [ length 1 - \ and <repetition> [ ] like ]
    tri 3append ;

MACRO: if-literals-match ( quots -- )
    [ length ] [ ] [ length ] tri
    ! n quots n n
    '[
        ! node quot
        [
            dup node-input-infos
            _ tail-slice* [ literal>> ] map
            dup _ check-elements
        ] dip
        swap [
            ! node literals quot
            [ _ firstn ] dip call
            drop
        ] [ 2drop emit-primitive ] if
    ] ;

: emit-vector-op ( node quot: ( rep -- ) -- )
    { [ representation? ] } if-literals-match ; inline

: [binary] ( quot -- quot' )
    '[ [ ds-drop 2inputs ] dip @ ds-push ] ; inline

: emit-binary-vector-op ( node quot -- )
    [binary] emit-vector-op ; inline

: [unary] ( quot -- quot' )
    '[ [ ds-drop ds-pop ] dip @ ds-push ] ; inline

: emit-unary-vector-op ( node quot -- )
    [unary] emit-vector-op ; inline

: [unary/param] ( quot -- quot' )
    '[ [ -2 inc-d ds-pop ] 2dip @ ds-push ] ; inline

: emit-horizontal-shift ( node quot -- )
    [unary/param]
    { [ integer? ] [ representation? ] } if-literals-match ; inline

: emit-gather-vector-2 ( node -- )
    [ ^^gather-vector-2 ] emit-binary-vector-op ;

: emit-gather-vector-4 ( node -- )
    [
        ds-drop
        [
            D 3 peek-loc
            D 2 peek-loc
            D 1 peek-loc
            D 0 peek-loc
            -4 inc-d
        ] dip
        ^^gather-vector-4
        ds-push
    ] emit-vector-op ;

: shuffle? ( obj -- ? ) { [ array? ] [ [ integer? ] all? ] } 1&& ;

: emit-shuffle-vector ( node -- )
    ! Pad the permutation with zeroes if its too short, since we
    ! can't throw an error at this point.
    [ [ rep-components 0 pad-tail ] keep ^^shuffle-vector ] [unary/param]
    { [ shuffle? ] [ representation? ] } if-literals-match ;

: ^^broadcast-vector ( src n rep -- dst )
    [ rep-components swap <array> ] keep
    ^^shuffle-vector ;

: emit-broadcast-vector ( node -- )
    [ ^^broadcast-vector ] [unary/param]
    { [ integer? ] [ representation? ] } if-literals-match ;

: ^^with-vector ( src rep -- dst )
    [ ^^scalar>vector ] keep [ 0 ] dip ^^broadcast-vector ;

: ^^select-vector ( src n rep -- dst )
    [ ^^broadcast-vector ] keep ^^vector>scalar ;

: emit-select-vector ( node -- )
    [ ^^select-vector ] [unary/param]
    { [ integer? ] [ representation? ] } if-literals-match ; inline

: emit-alien-vector ( node -- )
    dup [
        '[
            ds-drop prepare-alien-getter
            _ ^^alien-vector ds-push
        ]
        [ inline-alien-getter? ] inline-alien
    ] with emit-vector-op ;

: emit-set-alien-vector ( node -- )
    dup [
        '[
            ds-drop prepare-alien-setter ds-pop
            _ ##set-alien-vector
        ]
        [ byte-array inline-alien-setter? ]
        inline-alien
    ] with emit-vector-op ;
