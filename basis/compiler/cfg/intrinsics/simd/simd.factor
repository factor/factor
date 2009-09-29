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

: emit-binary-vector-op ( node quot -- )
    '[ [ ds-drop 2inputs ] dip @ ds-push ] 
    emit-vector-op ; inline

: emit-unary-vector-op ( node quot -- )
    '[ [ ds-drop ds-pop ] dip @ ds-push ]
    emit-vector-op ; inline

: emit-horizontal-shift ( node quot -- )
    '[ [ -2 inc-d ds-pop ] 2dip @ ds-push ]
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
    [ [ -2 inc-d ds-pop ] 2dip ^^shuffle-vector ds-push ]
    { [ shuffle? ] [ representation? ] } if-literals-match ; inline

: ^^broadcast-vector ( src rep -- dst )
    [ ^^scalar>vector ] keep
    [ rep-components 0 <array> ] keep
    ^^shuffle-vector ;

: emit-broadcast-vector ( node -- )
    [ ^^broadcast-vector ] emit-unary-vector-op ;

: ^^select-vector ( src n rep -- dst )
    [ rep-components swap <array> ] keep
    [ ^^shuffle-vector ] keep
    ^^vector>scalar ;

: emit-select-vector ( node -- )
    [ [ -2 inc-d ds-pop ] 2dip ^^select-vector ds-push ]
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
