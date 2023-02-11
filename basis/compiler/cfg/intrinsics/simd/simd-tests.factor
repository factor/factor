! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs biassocs byte-arrays classes
compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.intrinsics.simd compiler.cfg.intrinsics.simd.backend
compiler.cfg.stacks.local compiler.test compiler.tree
compiler.tree.propagation.info cpu.architecture fry kernel locals make
namespaces sequences system tools.test words ;
IN: compiler.cfg.intrinsics.simd.tests

:: test-node ( rep -- node )
    T{ #call
        { in-d  { 1 2 3 4 } }
        { out-d { 5 } }
        { info H{
            { 1 T{ value-info-state { class byte-array } } }
            { 2 T{ value-info-state { class byte-array } } }
            { 3 T{ value-info-state { class byte-array } } }
            { 4 T{ value-info-state { class word } { literal? t } { literal rep } } }
            { 5 T{ value-info-state { class byte-array } } }
        } }
    } ;

:: test-node-literal ( lit rep -- node )
    lit class-of :> lit-class
    T{ #call
        { in-d  { 1 2 3 4 } }
        { out-d { 5 } }
        { info H{
            { 1 T{ value-info-state { class byte-array } } }
            { 2 T{ value-info-state { class byte-array } } }
            { 3 T{ value-info-state { class lit-class } { literal? t } { literal lit } } }
            { 4 T{ value-info-state { class word } { literal? t } { literal rep } } }
            { 5 T{ value-info-state { class byte-array } } }
        } }
    } ;

: test-node-nonliteral-rep ( -- node )
    T{ #call
        { in-d  { 1 2 3 4 } }
        { out-d { 5 } }
        { info H{
            { 1 T{ value-info-state { class byte-array } } }
            { 2 T{ value-info-state { class byte-array } } }
            { 3 T{ value-info-state { class byte-array } } }
            { 4 T{ value-info-state { class object } } }
            { 5 T{ value-info-state { class byte-array } } }
        } }
    } ;

: test-compiler-env ( -- x )
    H{ } clone
    T{ basic-block } 0 0 0 0 height-state boa >>height
    \ basic-block pick set-at

    0 0 0 0 height-state boa \ height-state pick set-at
    HS{ } clone \ local-peek-set pick set-at
    H{ } clone \ replaces pick set-at
    H{ } <biassoc> \ locs>vregs pick set-at ;

: make-classes ( quot -- seq )
    { } make [ class-of ] map ; inline

: test-emit ( cpu rep quot -- node )
    [
        [ new \ cpu ] 2dip '[
            test-compiler-env [ _ test-node @ ] with-variables
        ] with-variable
    ] make-classes ; inline

: test-emit-literal ( cpu lit rep quot -- node )
    [
        [ new \ cpu ] 3dip '[
            test-compiler-env [ _ _ test-node-literal @ ] with-variables
        ] with-variable
    ] make-classes ; inline

: test-emit-nonliteral-rep ( cpu quot -- node )
    [
        [ new \ cpu ] dip '[
            test-compiler-env [ test-node-nonliteral-rep @ ] with-variables
        ] with-variable
    ] make-classes ; inline

CONSTANT: signed-reps
    { char-16-rep short-8-rep int-4-rep longlong-2-rep float-4-rep double-2-rep }
CONSTANT: all-reps
    {
        char-16-rep short-8-rep int-4-rep longlong-2-rep float-4-rep double-2-rep
        uchar-16-rep ushort-8-rep uint-4-rep ulonglong-2-rep
    }

TUPLE: scalar-cpu ;

TUPLE: simple-ops-cpu ;
M: simple-ops-cpu %zero-vector-reps all-reps ;
M: simple-ops-cpu %fill-vector-reps all-reps ;
M: simple-ops-cpu %add-vector-reps all-reps ;
M: simple-ops-cpu %sub-vector-reps all-reps ;
M: simple-ops-cpu %mul-vector-reps all-reps ;
M: simple-ops-cpu %div-vector-reps all-reps ;
M: simple-ops-cpu %andn-vector-reps all-reps ;
M: simple-ops-cpu %and-vector-reps all-reps ;
M: simple-ops-cpu %or-vector-reps all-reps ;
M: simple-ops-cpu %xor-vector-reps all-reps ;
M: simple-ops-cpu %merge-vector-reps all-reps ;
M: simple-ops-cpu %sqrt-vector-reps all-reps ;
M: simple-ops-cpu %move-vector-mask-reps  all-reps ;
M: simple-ops-cpu %test-vector-reps  all-reps ;
M: simple-ops-cpu %signed-pack-vector-reps all-reps ;
M: simple-ops-cpu %unsigned-pack-vector-reps all-reps ;
M: simple-ops-cpu %gather-vector-2-reps { longlong-2-rep ulonglong-2-rep double-2-rep } ;
M: simple-ops-cpu %gather-vector-4-reps { int-4-rep uint-4-rep float-4-rep } ;
M: simple-ops-cpu %alien-vector-reps all-reps ;

! v+
{ { ##add-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-v+ ] test-emit ]
unit-test

! v-
{ { ##sub-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-v- ] test-emit ]
unit-test

! vneg
{ { ##load-reference ##sub-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vneg ] test-emit ]
unit-test

{ { ##zero-vector ##sub-vector } }
[ simple-ops-cpu int-4-rep [ emit-simd-vneg ] test-emit ]
unit-test

! v*
{ { ##mul-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-v* ] test-emit ]
unit-test

! v/
{ { ##div-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-v/ ] test-emit ]
unit-test

TUPLE: addsub-cpu < simple-ops-cpu ;
M: addsub-cpu %add-sub-vector-reps { int-4-rep float-4-rep } ;

! v+-
{ { ##add-sub-vector } }
[ addsub-cpu float-4-rep [ emit-simd-v+- ] test-emit ]
unit-test

{ { ##load-reference ##xor-vector ##add-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-v+- ] test-emit ]
unit-test

{ { ##load-reference ##xor-vector ##sub-vector ##add-vector } }
[ simple-ops-cpu int-4-rep [ emit-simd-v+- ] test-emit ]
unit-test

TUPLE: saturating-cpu < simple-ops-cpu ;
M: saturating-cpu %saturated-add-vector-reps { int-4-rep } ;
M: saturating-cpu %saturated-sub-vector-reps { int-4-rep } ;
M: saturating-cpu %saturated-mul-vector-reps { int-4-rep } ;

! vs+
{ { ##add-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vs+ ] test-emit ]
unit-test

{ { ##add-vector } }
[ saturating-cpu float-4-rep [ emit-simd-vs+ ] test-emit ]
unit-test

{ { ##saturated-add-vector } }
[ saturating-cpu int-4-rep [ emit-simd-vs+ ] test-emit ]
unit-test

! vs-
{ { ##sub-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vs- ] test-emit ]
unit-test

{ { ##sub-vector } }
[ saturating-cpu float-4-rep [ emit-simd-vs- ] test-emit ]
unit-test

{ { ##saturated-sub-vector } }
[ saturating-cpu int-4-rep [ emit-simd-vs- ] test-emit ]
unit-test

! vs*
{ { ##mul-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vs* ] test-emit ]
unit-test

{ { ##mul-vector } }
[ saturating-cpu float-4-rep [ emit-simd-vs* ] test-emit ]
unit-test

{ { ##saturated-mul-vector } }
[ saturating-cpu int-4-rep [ emit-simd-vs* ] test-emit ]
unit-test

TUPLE: minmax-cpu < simple-ops-cpu ;
M: minmax-cpu %min-vector-reps signed-reps ;
M: minmax-cpu %max-vector-reps signed-reps ;
M: minmax-cpu %compare-vector-reps { cc= cc/= } member? [ signed-reps ] [ { } ] if ;
M: minmax-cpu %compare-vector-ccs nip f 2array 1array f ;

TUPLE: compare-cpu < simple-ops-cpu ;
M: compare-cpu %compare-vector-reps drop signed-reps ;
M: compare-cpu %compare-vector-ccs nip f 2array 1array f ;

! vmin
{ { ##min-vector } }
[ minmax-cpu float-4-rep [ emit-simd-vmin ] test-emit ]
unit-test

{ { ##compare-vector ##and-vector ##andn-vector ##or-vector } }
[ compare-cpu float-4-rep [ emit-simd-vmin ] test-emit ]
unit-test

! vmax
{ { ##max-vector } }
[ minmax-cpu float-4-rep [ emit-simd-vmax ] test-emit ]
unit-test

{ { ##compare-vector ##and-vector ##andn-vector ##or-vector } }
[ compare-cpu float-4-rep [ emit-simd-vmax ] test-emit ]
unit-test

TUPLE: dot-cpu < simple-ops-cpu ;
M: dot-cpu %dot-vector-reps { float-4-rep } ;

TUPLE: horizontal-cpu < simple-ops-cpu ;
M: horizontal-cpu %horizontal-add-vector-reps signed-reps ;
M: horizontal-cpu %unpack-vector-head-reps signed-reps ;
M: horizontal-cpu %unpack-vector-tail-reps signed-reps ;

! vdot
{ { ##dot-vector } }
[ dot-cpu float-4-rep [ emit-simd-vdot ] test-emit ]
unit-test

{ { ##mul-vector ##horizontal-add-vector ##horizontal-add-vector ##vector>scalar } }
[ horizontal-cpu float-4-rep [ emit-simd-vdot ] test-emit ]
unit-test

{ {
    ##mul-vector
    ##merge-vector-head ##merge-vector-tail ##add-vector
    ##merge-vector-head ##merge-vector-tail ##add-vector
    ##vector>scalar
} }
[ simple-ops-cpu float-4-rep [ emit-simd-vdot ] test-emit ]
unit-test

! vsqrt
{ { ##sqrt-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vsqrt ] test-emit ]
unit-test

! sum
{ { ##horizontal-add-vector ##vector>scalar } }
[ horizontal-cpu double-2-rep [ emit-simd-sum ] test-emit ]
unit-test

{ { ##horizontal-add-vector ##horizontal-add-vector ##vector>scalar } }
[ horizontal-cpu float-4-rep [ emit-simd-sum ] test-emit ]
unit-test

{ {
    ##unpack-vector-head ##unpack-vector-tail ##add-vector
    ##horizontal-add-vector ##horizontal-add-vector
    ##vector>scalar
} }
[ horizontal-cpu short-8-rep [ emit-simd-sum ] test-emit ]
unit-test

{ {
    ##unpack-vector-head ##unpack-vector-tail ##add-vector
    ##horizontal-add-vector ##horizontal-add-vector ##horizontal-add-vector
    ##vector>scalar
} }
[ horizontal-cpu char-16-rep [ emit-simd-sum ] test-emit ]
unit-test

TUPLE: abs-cpu < simple-ops-cpu ;
M: abs-cpu %abs-vector-reps signed-reps ;

! vabs
{ { } }
[ simple-ops-cpu uint-4-rep [ emit-simd-vabs ] test-emit ]
unit-test

{ { ##abs-vector } }
[ abs-cpu float-4-rep [ emit-simd-vabs ] test-emit ]
unit-test

{ { ##load-reference ##andn-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vabs ] test-emit ]
unit-test

{ { ##zero-vector ##sub-vector ##compare-vector ##and-vector ##andn-vector ##or-vector } }
[ compare-cpu int-4-rep [ emit-simd-vabs ] test-emit ]
unit-test

! vand
{ { ##and-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vand ] test-emit ]
unit-test

! vandn
{ { ##andn-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vandn ] test-emit ]
unit-test

! vor
{ { ##or-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vor ] test-emit ]
unit-test

! vxor
{ { ##xor-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vxor ] test-emit ]
unit-test

TUPLE: not-cpu < simple-ops-cpu ;
M: not-cpu %not-vector-reps signed-reps ;

! vnot
{ { ##not-vector } }
[ not-cpu float-4-rep [ emit-simd-vnot ] test-emit ]
unit-test

{ { ##fill-vector ##xor-vector } }
[ simple-ops-cpu float-4-rep [ emit-simd-vnot ] test-emit ]
unit-test

TUPLE: shift-cpu < simple-ops-cpu ;
M: shift-cpu %shl-vector-reps signed-reps ;
M: shift-cpu %shr-vector-reps signed-reps ;

TUPLE: shift-imm-cpu < simple-ops-cpu ;
M: shift-imm-cpu %shl-vector-imm-reps signed-reps ;
M: shift-imm-cpu %shr-vector-imm-reps signed-reps ;

TUPLE: horizontal-shift-cpu < simple-ops-cpu ;
M: horizontal-shift-cpu %horizontal-shl-vector-imm-reps signed-reps ;
M: horizontal-shift-cpu %horizontal-shr-vector-imm-reps signed-reps ;

! vlshift
{ { ##shl-vector-imm } }
[ shift-imm-cpu 2 int-4-rep [ emit-simd-vlshift ] test-emit-literal ]
unit-test

{ { ##shl-vector } }
[ shift-cpu int-4-rep [ emit-simd-vlshift ] test-emit ]
unit-test

! vrshift
{ { ##shr-vector-imm } }
[ shift-imm-cpu 2 int-4-rep [ emit-simd-vrshift ] test-emit-literal ]
unit-test

{ { ##shr-vector } }
[ shift-cpu int-4-rep [ emit-simd-vrshift ] test-emit ]
unit-test

! hlshift
{ { ##horizontal-shl-vector-imm } }
[ horizontal-shift-cpu 2 int-4-rep [ emit-simd-hlshift ] test-emit-literal ]
unit-test

! hrshift
{ { ##horizontal-shr-vector-imm } }
[ horizontal-shift-cpu 2 int-4-rep [ emit-simd-hrshift ] test-emit-literal ]
unit-test

TUPLE: shuffle-imm-cpu < simple-ops-cpu ;
M: shuffle-imm-cpu %shuffle-vector-imm-reps signed-reps ;

TUPLE: shuffle-cpu < simple-ops-cpu ;
M: shuffle-cpu %shuffle-vector-reps signed-reps ;

! vshuffle-elements
{ { ##load-reference ##shuffle-vector } }
[ shuffle-cpu { 0 1 2 3 } int-4-rep [ emit-simd-vshuffle-elements ] test-emit-literal ]
unit-test

{ { ##shuffle-vector-imm } }
[ shuffle-imm-cpu { 0 1 2 3 } int-4-rep [ emit-simd-vshuffle-elements ] test-emit-literal ]
unit-test

! vshuffle-bytes
{ { ##shuffle-vector } }
[ shuffle-cpu int-4-rep [ emit-simd-vshuffle-bytes ] test-emit ]
unit-test

! vmerge-head
{ { ##merge-vector-head } }
[ simple-ops-cpu float-4-rep [ emit-simd-vmerge-head ] test-emit ]
unit-test

! vmerge-tail
{ { ##merge-vector-tail } }
[ simple-ops-cpu float-4-rep [ emit-simd-vmerge-tail ] test-emit ]
unit-test

! v<= etc.
{ { ##compare-vector } }
[ compare-cpu int-4-rep [ emit-simd-v<= ] test-emit ]
unit-test

{ { ##min-vector ##compare-vector } }
[ minmax-cpu int-4-rep [ emit-simd-v<= ] test-emit ]
unit-test

{ { ##load-reference ##xor-vector ##xor-vector ##compare-vector } }
[ compare-cpu uint-4-rep [ emit-simd-v<= ] test-emit ]
unit-test

! vany? etc.
{ { ##test-vector } }
[ simple-ops-cpu int-4-rep [ emit-simd-vany? ] test-emit ]
unit-test

TUPLE: convert-cpu < simple-ops-cpu ;
M: convert-cpu %integer>float-vector-reps { int-4-rep } ;
M: convert-cpu %float>integer-vector-reps { float-4-rep } ;

! v>float
{ { } }
[ convert-cpu float-4-rep [ emit-simd-v>float ] test-emit ]
unit-test

{ { ##integer>float-vector } }
[ convert-cpu int-4-rep [ emit-simd-v>float ] test-emit ]
unit-test

! v>integer
{ { } }
[ convert-cpu int-4-rep [ emit-simd-v>integer ] test-emit ]
unit-test

{ { ##float>integer-vector } }
[ convert-cpu float-4-rep [ emit-simd-v>integer ] test-emit ]
unit-test

! vpack-signed
{ { ##signed-pack-vector } }
[ simple-ops-cpu int-4-rep [ emit-simd-vpack-signed ] test-emit ]
unit-test

! vpack-unsigned
{ { ##unsigned-pack-vector } }
[ simple-ops-cpu int-4-rep [ emit-simd-vpack-unsigned ] test-emit ]
unit-test

TUPLE: unpack-head-cpu < simple-ops-cpu ;
M: unpack-head-cpu %unpack-vector-head-reps all-reps ;
TUPLE: unpack-cpu < unpack-head-cpu ;
M: unpack-cpu %unpack-vector-tail-reps all-reps ;

! vunpack-head
{ { ##unpack-vector-head } }
[ unpack-head-cpu int-4-rep [ emit-simd-vunpack-head ] test-emit ]
unit-test

{ { ##zero-vector ##merge-vector-head } }
[ simple-ops-cpu uint-4-rep [ emit-simd-vunpack-head ] test-emit ]
unit-test

{ { ##merge-vector-head ##shr-vector-imm } }
[ shift-imm-cpu int-4-rep [ emit-simd-vunpack-head ] test-emit ]
unit-test

{ { ##zero-vector ##compare-vector ##merge-vector-head } }
[ compare-cpu int-4-rep [ emit-simd-vunpack-head ] test-emit ]
unit-test

! vunpack-tail
{ { ##unpack-vector-tail } }
[ unpack-cpu int-4-rep [ emit-simd-vunpack-tail ] test-emit ]
unit-test

{ { ##tail>head-vector ##unpack-vector-head } }
[ unpack-head-cpu int-4-rep [ emit-simd-vunpack-tail ] test-emit ]
unit-test

{ { ##zero-vector ##merge-vector-tail } }
[ simple-ops-cpu uint-4-rep [ emit-simd-vunpack-tail ] test-emit ]
unit-test

{ { ##merge-vector-tail ##shr-vector-imm } }
[ shift-imm-cpu int-4-rep [ emit-simd-vunpack-tail ] test-emit ]
unit-test

{ { ##zero-vector ##compare-vector ##merge-vector-tail } }
[ compare-cpu int-4-rep [ emit-simd-vunpack-tail ] test-emit ]
unit-test

! with
{ { ##scalar>vector ##shuffle-vector-imm } }
[ shuffle-imm-cpu float-4-rep [ emit-simd-with ] test-emit ]
unit-test

! gather-2
{ { ##gather-vector-2 } }
[ simple-ops-cpu double-2-rep [ emit-simd-gather-2 ] test-emit ]
unit-test

! gather-4
{ { ##gather-vector-4 } }
[ simple-ops-cpu float-4-rep [ emit-simd-gather-4 ] test-emit ]
unit-test

! select
{ { ##shuffle-vector-imm ##vector>scalar } }
[ shuffle-imm-cpu 1 float-4-rep [ emit-simd-select ] test-emit-literal ]
unit-test

! ^load-neg-zero-vector
{
    V{
        T{ ##load-reference
           { dst 1 }
           { obj B{ 0 0 0 128 0 0 0 128 0 0 0 128 0 0 0 128 } }
        }
        T{ ##load-reference
           { dst 2 }
           { obj B{ 0 0 0 0 0 0 0 128 0 0 0 0 0 0 0 128 } }
        }
    }
} [
    [
        { float-4-rep double-2-rep } [ ^load-neg-zero-vector drop ] each
    ] V{ } make
] cfg-unit-test

! ^load-add-sub-vector
{
    V{
        T{ ##load-reference
           { dst 1 }
           { obj B{ 0 0 0 128 0 0 0 0 0 0 0 128 0 0 0 0 } }
        }
        T{ ##load-reference
           { dst 2 }
           { obj B{ 0 0 0 0 0 0 0 128 0 0 0 0 0 0 0 0 } }
        }
        T{ ##load-reference
           { dst 3 }
           { obj
             B{ 255 0 255 0 255 0 255 0 255 0 255 0 255 0 255 0 }
           }
        }
        T{ ##load-reference
           { dst 4 }
           { obj
             B{ 255 255 0 0 255 255 0 0 255 255 0 0 255 255 0 0 }
           }
        }
        T{ ##load-reference
           { dst 5 }
           { obj
             B{ 255 255 255 255 0 0 0 0 255 255 255 255 0 0 0 0 }
           }
        }
        T{ ##load-reference
           { dst 6 }
           { obj
             B{ 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 }
           }
        }
    }
} [
    [
        {
            float-4-rep
            double-2-rep
            char-16-rep
            short-8-rep
            int-4-rep
            longlong-2-rep
        } [ ^load-add-sub-vector drop ] each
    ] V{ } make
] cfg-unit-test

! ^load-half-vector
{
    V{
        T{ ##load-reference
           { dst 1 }
           { obj B{ 0 0 0 63 0 0 0 63 0 0 0 63 0 0 0 63 } }
        }
        T{ ##load-reference
           { dst 2 }
           { obj B{ 0 0 0 0 0 0 224 63 0 0 0 0 0 0 224 63 } }
        }
    }
} [
    [
        { float-4-rep double-2-rep } [ ^load-half-vector drop ] each
    ] V{ } make
] cfg-unit-test

! sign-bit-mask
{
    {
        B{ 128 128 128 128 128 128 128 128 128 128 128 128 128 128 128 128 }
        B{ 0 128 0 128 0 128 0 128 0 128 0 128 0 128 0 128 }
        B{ 0 0 0 128 0 0 0 128 0 0 0 128 0 0 0 128 }
        B{ 0 0 0 0 0 0 0 128 0 0 0 0 0 0 0 128 }
    }
} [
    { char-16-rep short-8-rep int-4-rep longlong-2-rep } [ sign-bit-mask ] map
] unit-test


! test with nonliteral/invalid reps
[ simple-ops-cpu [ emit-simd-v+ ] test-emit-nonliteral-rep ]
[ bad-simd-intrinsic? ] must-fail-with

[ simple-ops-cpu f [ emit-simd-v+ ] test-emit ]
[ bad-simd-intrinsic? ] must-fail-with

[ simple-ops-cpu 3 [ emit-simd-v+ ] test-emit ]
[ bad-simd-intrinsic? ] must-fail-with
