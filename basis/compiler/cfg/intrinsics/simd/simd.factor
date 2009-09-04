! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays fry cpu.architecture kernel
sequences compiler.tree.propagation.info
compiler.cfg.builder.blocks compiler.cfg.stacks
compiler.cfg.stacks.local compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.intrinsics.alien ;
IN: compiler.cfg.intrinsics.simd

: emit-vector-op ( node quot: ( rep -- ) -- )
    [ dup node-input-infos last literal>> ] dip over representation?
    [ [ drop ] 2dip call ] [ 2drop emit-primitive ] if ; inline

: emit-binary-vector-op ( node quot -- )
    '[ [ ds-drop 2inputs ] dip @ ds-push ] emit-vector-op ; inline

: emit-unary-vector-op ( node quot -- )
    '[ [ ds-drop ds-pop ] dip @ ds-push ] emit-vector-op ; inline

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
