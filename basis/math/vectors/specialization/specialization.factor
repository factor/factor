! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel make sequences effects sets kernel.private
accessors combinators math math.intervals math.vectors
math.vectors.conversion.backend namespaces assocs fry splitting
classes.algebra generalizations locals
compiler.tree.propagation.info ;
IN: math.vectors.specialization

SYMBOLS: -> +vector+ +any-vector+ +scalar+ +boolean+ +nonnegative+ +literal+ ;

: parent-vector-class ( type -- type' )
    {
        { [ dup simd-128 class<= ] [ drop simd-128 ] }
        { [ dup simd-256 class<= ] [ drop simd-256 ] }
        [ "Not a vector class" throw ]
    } cond ;

: signature-for-schema ( array-type elt-type schema -- signature )
    [
        {
            { +vector+ [ drop ] }
            { +any-vector+ [ drop parent-vector-class ] }
            { +scalar+ [ nip ] }
            { +boolean+ [ 2drop boolean ] }
            { +nonnegative+ [ nip ] }
            { +literal+ [ 2drop f ] }
        } case
    ] with with map ;

: (specialize-vector-word) ( word array-type elt-type schema -- word' )
    signature-for-schema
    [ [ name>> ] [ [ name>> ] map "," join ] bi* "=>" glue f <word> ]
    [ [ , \ declare , def>> % ] [ ] make ]
    [ drop stack-effect ]
    2tri
    [ define-declared ] [ 2drop ] 3bi ;

: output-infos ( array-type elt-type schema -- value-infos )
    [
        {
            { +vector+ [ drop <class-info> ] }
            { +any-vector+ [ drop parent-vector-class <class-info> ] }
            { +scalar+ [ nip <class-info> ] }
            { +boolean+ [ 2drop boolean <class-info> ] }
            {
                +nonnegative+
                [
                    nip
                    dup complex class<= [ drop float ] when
                    [0,inf] <class/interval-info>
                ]
            }
        } case
    ] with with map ;

: record-output-signature ( word array-type elt-type schema -- word )
    output-infos
    [ drop ]
    [ drop ]
    [ [ stack-effect in>> length '[ _ ndrop ] ] dip append ] 2tri
    "outputs" set-word-prop ;

CONSTANT: vector-words
H{
    { [v-] { +vector+ +vector+ -> +vector+ } }
    { distance { +vector+ +vector+ -> +nonnegative+ } }
    { n*v { +scalar+ +vector+ -> +vector+ } }
    { n+v { +scalar+ +vector+ -> +vector+ } }
    { n-v { +scalar+ +vector+ -> +vector+ } }
    { n/v { +scalar+ +vector+ -> +vector+ } }
    { norm { +vector+ -> +nonnegative+ } }
    { norm-sq { +vector+ -> +nonnegative+ } }
    { normalize { +vector+ -> +vector+ } }
    { v* { +vector+ +vector+ -> +vector+ } }
    { vs* { +vector+ +vector+ -> +vector+ } }
    { v*n { +vector+ +scalar+ -> +vector+ } }
    { v+ { +vector+ +vector+ -> +vector+ } }
    { vs+ { +vector+ +vector+ -> +vector+ } }
    { v+- { +vector+ +vector+ -> +vector+ } }
    { v+n { +vector+ +scalar+ -> +vector+ } }
    { v- { +vector+ +vector+ -> +vector+ } }
    { vneg { +vector+ -> +vector+ } }
    { vs- { +vector+ +vector+ -> +vector+ } }
    { v-n { +vector+ +scalar+ -> +vector+ } }
    { v. { +vector+ +vector+ -> +scalar+ } }
    { v/ { +vector+ +vector+ -> +vector+ } }
    { v/n { +vector+ +scalar+ -> +vector+ } }
    { vceiling { +vector+ -> +vector+ } }
    { vfloor { +vector+ -> +vector+ } }
    { vmax { +vector+ +vector+ -> +vector+ } }
    { vmin { +vector+ +vector+ -> +vector+ } }
    { vneg { +vector+ -> +vector+ } }
    { vtruncate { +vector+ -> +vector+ } }
    { sum { +vector+ -> +scalar+ } }
    { vabs { +vector+ -> +vector+ } }
    { vsqrt { +vector+ -> +vector+ } }
    { vbitand { +vector+ +vector+ -> +vector+ } }
    { vbitandn { +vector+ +vector+ -> +vector+ } }
    { vbitor { +vector+ +vector+ -> +vector+ } }
    { vbitxor { +vector+ +vector+ -> +vector+ } }
    { vbitnot { +vector+ -> +vector+ } }
    { vand { +vector+ +vector+ -> +vector+ } }
    { vandn { +vector+ +vector+ -> +vector+ } }
    { vor { +vector+ +vector+ -> +vector+ } }
    { vxor { +vector+ +vector+ -> +vector+ } }
    { vnot { +vector+ -> +vector+ } }
    { vlshift { +vector+ +scalar+ -> +vector+ } }
    { vrshift { +vector+ +scalar+ -> +vector+ } }
    { hlshift { +vector+ +literal+ -> +vector+ } }
    { hrshift { +vector+ +literal+ -> +vector+ } }
    { vshuffle-elements { +vector+ +literal+ -> +vector+ } }
    { vshuffle-bytes    { +vector+ +any-vector+  -> +vector+ } }
    { vbroadcast { +vector+ +literal+ -> +vector+ } }
    { (vmerge-head) { +vector+ +vector+ -> +vector+ } }
    { (vmerge-tail) { +vector+ +vector+ -> +vector+ } }
    { (v>float) { +vector+ +literal+ -> +vector+ } }
    { (v>integer) { +vector+ +literal+ -> +vector+ } }
    { (vpack-signed) { +vector+ +vector+ +literal+ -> +vector+ } }
    { (vpack-unsigned) { +vector+ +vector+ +literal+ -> +vector+ } }
    { (vunpack-head) { +vector+ +literal+ -> +vector+ } }
    { (vunpack-tail) { +vector+ +literal+ -> +vector+ } }
    { v<= { +vector+ +vector+ -> +vector+ } }
    { v< { +vector+ +vector+ -> +vector+ } }
    { v= { +vector+ +vector+ -> +vector+ } }
    { v> { +vector+ +vector+ -> +vector+ } }
    { v>= { +vector+ +vector+ -> +vector+ } }
    { vunordered? { +vector+ +vector+ -> +vector+ } }
    { vany?  { +vector+ -> +boolean+ } }
    { vall?  { +vector+ -> +boolean+ } }
    { vnone? { +vector+ -> +boolean+ } }
}

PREDICATE: vector-word < word vector-words key? ;

: specializations ( word -- assoc )
    dup "specializations" word-prop
    [ ] [ V{ } clone [ "specializations" set-word-prop ] keep ] ?if ;

M: vector-word subwords specializations values [ word? ] filter ;

: add-specialization ( new-word signature word -- )
    specializations set-at ;

ERROR: bad-vector-word word ;

: word-schema ( word -- schema )
    vector-words ?at [ bad-vector-word ] unless ;

: inputs ( schema -- seq ) { -> } split first ;

: outputs ( schema -- seq ) { -> } split second ;

: loop-vector-op ( word array-type elt-type -- word' )
    pick word-schema
    [ inputs (specialize-vector-word) ]
    [ outputs record-output-signature ] 3bi ;

:: specialize-vector-word ( word array-type elt-type simd -- word/quot' )
    word simd key? [ word simd at ] [ word array-type elt-type loop-vector-op ] if ;

:: input-signature ( word array-type elt-type -- signature )
    array-type elt-type word word-schema inputs signature-for-schema ;

: vector-words-for-type ( elt-type -- words )
    {
        ! Can't do shifts on floats
        { [ dup float class<= ] [ vector-words keys { vlshift vrshift } diff ] }
        ! Can't divide integers
        { [ dup integer class<= ] [ vector-words keys { vsqrt n/v v/n v/ normalize } diff ] }
        ! Can't compute square root of complex numbers (vsqrt uses fsqrt not sqrt)
        { [ dup complex class<= ] [ vector-words keys { vsqrt } diff ] }
        [ { } ]
    } cond
    ! Don't specialize horizontal shifts, shuffles, and conversions at all, they're only for SIMD
    {
        hlshift hrshift vshuffle-elements vshuffle-bytes vbroadcast
        (v>integer) (v>float)
        (vpack-signed) (vpack-unsigned)
        (vunpack-head) (vunpack-tail)
    } diff
    nip ;

:: specialize-vector-words ( array-type elt-type simd -- )
    elt-type vector-words-for-type simd keys union [
        [ array-type elt-type simd specialize-vector-word ]
        [ array-type elt-type input-signature ]
        [ ]
        tri add-specialization
    ] each ;

: specialization-matches? ( value-infos signature -- ? )
    [ [ [ class>> ] dip class<= ] [ literal?>> ] if* ] 2all? ;

: find-specialization ( classes word -- word/f )
    specializations
    [ first specialization-matches? ] with find
    swap [ second ] when ;

: vector-word-custom-inlining ( #call -- word/f )
    [ in-d>> [ value-info ] map ] [ word>> ] bi
    find-specialization ;

vector-words keys [
    [ vector-word-custom-inlining ]
    "custom-inlining" set-word-prop
] each
