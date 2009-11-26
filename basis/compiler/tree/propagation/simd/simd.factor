! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs byte-arrays combinators compiler.cfg.builder
continuations fry sequences compiler.tree.propagation.info
cpu.architecture kernel words make math math.intervals
math.vectors.simd.intrinsics namespaces ;
IN: compiler.tree.propagation.simd

CONSTANT: vector>vector-intrinsics
    {
        (simd-v+)
        (simd-v-)
        (simd-vneg)
        (simd-v+-)
        (simd-vs+)
        (simd-vs-)
        (simd-vs*)
        (simd-v*)
        (simd-v/)
        (simd-vmin)
        (simd-vmax)
        (simd-vsqrt)
        (simd-vabs)
        (simd-vbitand)
        (simd-vbitandn)
        (simd-vbitor)
        (simd-vbitxor)
        (simd-vbitnot)
        (simd-vand)
        (simd-vandn)
        (simd-vor)
        (simd-vxor)
        (simd-vnot)
        (simd-vlshift)
        (simd-vrshift)
        (simd-hlshift)
        (simd-hrshift)
        (simd-vshuffle-elements)
        (simd-vshuffle-bytes)
        (simd-vmerge-head)
        (simd-vmerge-tail)
        (simd-v<=)
        (simd-v<)
        (simd-v=)
        (simd-v>)
        (simd-v>=)
        (simd-vunordered?)
        (simd-v>float)
        (simd-v>integer)
        (simd-vpack-signed)
        (simd-vpack-unsigned)
        (simd-vunpack-head)
        (simd-vunpack-tail)
        (simd-with)
        (simd-gather-2)
        (simd-gather-4)
        alien-vector
    }

CONSTANT: vector-other-intrinsics
    {
        (simd-v.)
        (simd-sum)
        (simd-vany?)
        (simd-vall?)
        (simd-vnone?)
        (simd-select)
        set-alien-vector
    }

: vector-intrinsics ( -- x )
    vector>vector-intrinsics vector-other-intrinsics append ;

vector>vector-intrinsics [ { byte-array } "default-output-classes" set-word-prop ] each

: scalar-output-class ( rep -- class )
    dup literal?>> [
        literal>> scalar-rep-of {
            { float-rep [ float ] }
            { double-rep [ float ] }
            [ drop integer ]
        } case
    ] [ drop real ] if
    <class-info> ;

\ (simd-sum) [ nip scalar-output-class ] "outputs" set-word-prop

\ (simd-v.) [ 2nip scalar-output-class ] "outputs" set-word-prop

{
    (simd-vany?)
    (simd-vall?)
    (simd-vnone?)
} [ { boolean } "default-output-classes" set-word-prop ] each

\ (simd-select) [ 2nip scalar-output-class ] "outputs" set-word-prop

\ assert-positive [
    real [0,inf] <class/interval-info> value-info-intersect
] "outputs" set-word-prop

: clone-with-value-infos ( node -- node' )
    clone dup in-d>> [ dup value-info ] H{ } map>assoc >>info ;

: try-intrinsic ( node intrinsic-quot -- ? )
    '[
        _ clone-with-value-infos
        _ with-dummy-cfg-builder
        t
    ] [ drop f ] recover ;

: inline-unless-intrinsic ( word -- )
    dup '[
        _ swap over "intrinsic" word-prop
        "always-inline-simd-intrinsics" get not swap and
        ! word node intrinsic
        [ try-intrinsic [ drop f ] [ def>> ] if ]
        [ drop def>> ] if*
    ]
    "custom-inlining" set-word-prop ;

vector-intrinsics [ inline-unless-intrinsic ] each
