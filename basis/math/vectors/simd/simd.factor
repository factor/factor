! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types byte-arrays cpu.architecture
generalizations kernel math math.functions math.vectors
math.vectors.simd.functor math.vectors.specialization parser
prettyprint.custom sequences sequences.private
specialized-arrays.double locals assocs literals ;
IN: math.vectors.simd

<PRIVATE

ERROR: bad-simd-call ;

: (simd-v+) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v-) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v*) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v/) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vmin) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vmax) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vsqrt) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-sum) ( v1 rep -- v2 ) bad-simd-call ;
: (simd-broadcast) ( x rep -- v ) bad-simd-call ;
: (simd-gather-2) ( a b rep -- v ) bad-simd-call ;
: (simd-gather-4) ( a b c d rep -- v ) bad-simd-call ;
: assert-positive ( x -- y ) ;

PRIVATE>

<<

DEFER: 4float-array
DEFER: 2double-array

"double" 2 define-simd-type
"float" 4 define-simd-type

>>

! Constructors
: 4float-array-with ( x -- simd-array )
    >float 4float-array-rep (simd-broadcast) 4float-array boa ; inline

: 4float-array-boa ( a b c d -- simd-array )
    [ >float ] 4 napply 4float-array-rep (simd-gather-4) 4float-array boa ; inline

: 2double-array-with ( x -- simd-array )
    >float 2double-array-rep (simd-broadcast) 2double-array boa ; inline

: 2double-array-boa ( a b -- simd-array )
    [ >float ] bi@ 2double-array-rep (simd-gather-2) 2double-array boa ; inline

<PRIVATE

: 4float-array-vv->v-op ( v1 v2 quot -- v3 )
    [ [ underlying>> ] bi@ 4float-array-rep ] dip call 4float-array boa ; inline

: 4float-array-v->n-op ( v1 quot -- v2 )
    [ underlying>> 4float-array-rep ] dip call ; inline

: 2double-array-vv->v-op ( v1 v2 quot -- v3 )
    [ [ underlying>> ] bi@ 2double-array-rep ] dip call 2double-array boa ; inline

: 2double-array-v->n-op ( v1 quot -- v2 )
    [ underlying>> 2double-array-rep ] dip call ; inline

PRIVATE>

<<

<PRIVATE

:: simd-vector-words ( class ctor elt-type assoc -- )
    class elt-type assoc {
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
    } assoc-union
    specialize-vector-words ;

PRIVATE>

\ 4float-array \ 4float-array-with float H{
    { v+ [ [ (simd-v+) ] 4float-array-vv->v-op ] }
    { v- [ [ (simd-v-) ] 4float-array-vv->v-op ] }
    { v* [ [ (simd-v*) ] 4float-array-vv->v-op ] }
    { v/ [ [ (simd-v/) ] 4float-array-vv->v-op ] }
    { vmin [ [ (simd-vmin) ] 4float-array-vv->v-op ] }
    { vmax [ [ (simd-vmax) ] 4float-array-vv->v-op ] }
    { sum [ [ (simd-sum) ] 4float-array-v->n-op ] }
} simd-vector-words

\ 2double-array \ 2double-array-with float H{
    { v+ [ [ (simd-v+) ] 2double-array-vv->v-op ] }
    { v- [ [ (simd-v-) ] 2double-array-vv->v-op ] }
    { v* [ [ (simd-v*) ] 2double-array-vv->v-op ] }
    { v/ [ [ (simd-v/) ] 2double-array-vv->v-op ] }
    { vmin [ [ (simd-vmin) ] 2double-array-vv->v-op ] }
    { vmax [ [ (simd-vmax) ] 2double-array-vv->v-op ] }
    { sum [ [ (simd-sum) ] 2double-array-v->n-op ] }
} simd-vector-words

>>

! Synthesize 256-bit vectors from a pair of 128-bit vectors
! Functorize this later so that we can do it for integers, etc
TUPLE: 4double-array
{ underlying1 byte-array initial: $[ 16 <byte-array> ] read-only }
{ underlying2 byte-array initial: $[ 16 <byte-array> ] read-only } ;

: <4double-array> ( -- simd-array )
    16 <byte-array> 16 <byte-array> 4double-array boa ; inline

: (4double-array) ( -- simd-array )
    16 (byte-array) 16 (byte-array) 4double-array boa ; inline

M: 4double-array clone
    [ underlying1>> clone ] [ underlying2>> clone ] bi
    4double-array boa ; inline

M: 4double-array length drop 4 ; inline

<PRIVATE

: 4double-array-deref ( n seq -- n' seq' )
    over 2 < [ underlying1>> ] [ [ 2 - ] dip underlying2>> ] if
    2 swap double-array boa ; inline

PRIVATE>

M: 4double-array nth-unsafe
    4double-array-deref nth-unsafe ; inline

M: 4double-array set-nth-unsafe
    4double-array-deref set-nth-unsafe ; inline

: >4double-array ( seq -- simd-array )
    4double-array new clone-like ;

M: 4double-array like
    drop dup 4double-array? [ >4double-array ] unless ; inline

M: 4double-array new-sequence
    drop dup 4 = [ drop (4double-array) ] [ 4 bad-length ] if ; inline

M: 4double-array equal?
    over 4double-array? [ sequence= ] [ 2drop f ] if ;

M: 4double-array byte-length drop 32 ; inline

SYNTAX: 4double-array{
    \ } [ >4double-array ] parse-literal ;

M: 4double-array pprint-delims
    drop \ 4double-array{ \ } ;

M: 4double-array >pprint-sequence ;

M: 4double-array pprint* pprint-object ;

INSTANCE: 4double-array sequence

: 4double-array-with ( x -- simd-array )
    dup [ >float 2double-array-rep (simd-broadcast) ] bi@
    4double-array boa ; inline

: 4double-array-boa ( a b c d -- simd-array )
    [ >float ] 4 napply [ 2double-array-rep (simd-gather-2) ] 2bi@
    4double-array boa ; inline

! SIMD operations on 4double-arrays

<PRIVATE

: 4double-array-vv->v-op ( v1 v2 quot -- v3 )
    [ [ [ underlying1>> ] bi@ 2double-array-rep ] dip call ]
    [ [ [ underlying2>> ] bi@ 2double-array-rep ] dip call ] 3bi
    4double-array boa ; inline

: 4double-array-v->n-op ( v1 quot scalar-quot -- v2 )
    [
        [ [ underlying1>> 2double-array-rep ] dip call ]
        [ [ underlying2>> 2double-array-rep ] dip call ] 2bi
    ] dip call ; inline

PRIVATE>

<<

\ 4double-array \ 4double-array-with float H{
    { v+ [ [ (simd-v+) ] 4double-array-vv->v-op ] }
    { v- [ [ (simd-v-) ] 4double-array-vv->v-op ] }
    { v* [ [ (simd-v*) ] 4double-array-vv->v-op ] }
    { v/ [ [ (simd-v/) ] 4double-array-vv->v-op ] }
    { vmin [ [ (simd-vmin) ] 4double-array-vv->v-op ] }
    { vmax [ [ (simd-vmax) ] 4double-array-vv->v-op ] }
    { sum [ [ (simd-sum) ] [ + ] 4double-array-v->n-op ] }
} simd-vector-words

>>

USE: vocabs.loader

"math.vectors.simd.alien" require
