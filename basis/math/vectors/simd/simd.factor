! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types byte-arrays cpu.architecture
kernel math math.functions math.vectors
math.vectors.simd.functor math.vectors.simd.intrinsics
math.vectors.specialization parser prettyprint.custom sequences
sequences.private specialized-arrays.double locals assocs
words fry ;
IN: math.vectors.simd

<<

DEFER: float-4
DEFER: double-2
DEFER: float-8
DEFER: double-4

"double" define-simd-128
"float" define-simd-128
"double" define-simd-256
"float" define-simd-256

>>

: float-4-with ( x -- simd-array )
    >float float-4-rep (simd-broadcast) float-4 boa ; inline

:: float-4-boa ( a b c d -- simd-array )
    a >float b >float c >float d >float
    float-4-rep (simd-gather-4) float-4 boa ; inline

: double-2-with ( x -- simd-array )
    >float double-2-rep (simd-broadcast) double-2 boa ; inline

: double-2-boa ( a b -- simd-array )
    [ >float ] bi@ double-2-rep (simd-gather-2) double-2 boa ; inline

: float-8-with ( x -- simd-array )
    [ float-4-with ] [ float-4-with ] bi [ underlying>> ] bi@
    float-8 boa ; inline

:: float-8-boa ( a b c d e f g h -- simd-array )
    a b c d float-4-boa
    e f g h float-4-boa
    [ underlying>> ] bi@
    float-8 boa ; inline

: double-4-with ( x -- simd-array )
    [ double-2-with ] [ double-2-with ] bi [ underlying>> ] bi@
    double-4 boa ; inline

:: double-4-boa ( a b c d -- simd-array )
    a b double-2-boa
    c d double-2-boa
    [ underlying>> ] bi@
    double-4 boa ; inline

<<

<PRIVATE

: supported-simd-ops ( assoc -- assoc' )
    {
        { v+ (simd-v+) }
        { v- (simd-v-) }
        { v* (simd-v*) }
        { v/ (simd-v/) }
        { vmin (simd-vmin) }
        { vmax (simd-vmax) }
        { sum (simd-sum) }
    } [ nip "intrinsic" word-prop ] assoc-filter
    '[ drop _ key? ] assoc-filter ;

:: high-level-ops ( ctor -- assoc )
    ! Some SIMD operations are defined in terms of others.
    {
        { vneg [ [ dup v- ] keep v- ] }
        { v. [ v* sum ] }
        { n+v [ [ ctor execute ] dip v+ ] }
        { v+n [ ctor execute v+ ] }
        { n-v [ [ ctor execute ] dip v- ] }
        { v-n [ ctor execute v- ] }
        { n*v [ [ ctor execute ] dip v* ] }
        { v*n [ ctor execute v* ] }
        { n/v [ [ ctor execute ] dip v/ ] }
        { v/n [ ctor execute v/ ] }
        { norm-sq [ dup v. assert-positive ] }
        { norm [ norm-sq sqrt ] }
        { normalize [ dup norm v/n ] }
        { distance [ v- norm ] }
    } ;

:: simd-vector-words ( class ctor elt-type assoc -- )
    class elt-type assoc supported-simd-ops ctor high-level-ops assoc-union
    specialize-vector-words ;

PRIVATE>

\ float-4 \ float-4-with float H{
    { v+ [ [ (simd-v+) ] float-4-vv->v-op ] }
    { v- [ [ (simd-v-) ] float-4-vv->v-op ] }
    { v* [ [ (simd-v*) ] float-4-vv->v-op ] }
    { v/ [ [ (simd-v/) ] float-4-vv->v-op ] }
    { vmin [ [ (simd-vmin) ] float-4-vv->v-op ] }
    { vmax [ [ (simd-vmax) ] float-4-vv->v-op ] }
    { sum [ [ (simd-sum) ] float-4-v->n-op ] }
} simd-vector-words

\ double-2 \ double-2-with float H{
    { v+ [ [ (simd-v+) ] double-2-vv->v-op ] }
    { v- [ [ (simd-v-) ] double-2-vv->v-op ] }
    { v* [ [ (simd-v*) ] double-2-vv->v-op ] }
    { v/ [ [ (simd-v/) ] double-2-vv->v-op ] }
    { vmin [ [ (simd-vmin) ] double-2-vv->v-op ] }
    { vmax [ [ (simd-vmax) ] double-2-vv->v-op ] }
    { sum [ [ (simd-sum) ] double-2-v->n-op ] }
} simd-vector-words

\ float-8 \ float-8-with float H{
    { v+ [ [ (simd-v+) ] float-8-vv->v-op ] }
    { v- [ [ (simd-v-) ] float-8-vv->v-op ] }
    { v* [ [ (simd-v*) ] float-8-vv->v-op ] }
    { v/ [ [ (simd-v/) ] float-8-vv->v-op ] }
    { vmin [ [ (simd-vmin) ] float-8-vv->v-op ] }
    { vmax [ [ (simd-vmax) ] float-8-vv->v-op ] }
    { sum [ [ (simd-sum) ] [ + ] float-8-v->n-op ] }
} simd-vector-words

\ double-4 \ double-4-with float H{
    { v+ [ [ (simd-v+) ] double-4-vv->v-op ] }
    { v- [ [ (simd-v-) ] double-4-vv->v-op ] }
    { v* [ [ (simd-v*) ] double-4-vv->v-op ] }
    { v/ [ [ (simd-v/) ] double-4-vv->v-op ] }
    { vmin [ [ (simd-vmin) ] double-4-vv->v-op ] }
    { vmax [ [ (simd-vmax) ] double-4-vv->v-op ] }
    { sum [ [ (simd-sum) ] [ + ] double-4-v->n-op ] }
} simd-vector-words

>>

USE: vocabs.loader

"math.vectors.simd.alien" require
