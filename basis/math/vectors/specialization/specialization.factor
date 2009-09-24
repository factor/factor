! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel make sequences effects sets kernel.private
accessors combinators math math.intervals math.vectors
namespaces assocs fry splitting classes.algebra generalizations
locals compiler.tree.propagation.info ;
IN: math.vectors.specialization

SYMBOLS: -> +vector+ +scalar+ +nonnegative+ ;

: signature-for-schema ( array-type elt-type schema -- signature )
    [
        {
            { +vector+ [ drop ] }
            { +scalar+ [ nip ] }
            { +nonnegative+ [ nip ] }
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
            { +scalar+ [ nip <class-info> ] }
            { +nonnegative+ [ nip real class-and [0,inf] <class/interval-info> ] }
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
    { vbitor { +vector+ +vector+ -> +vector+ } }
    { vbitxor { +vector+ +vector+ -> +vector+ } }
    { v>> { +vector+ +scalar+ -> +vector+ } }
    { v<< { +vector+ +scalar+ -> +vector+ } }
}

PREDICATE: vector-word < word vector-words key? ;

: specializations ( word -- assoc )
    dup "specializations" word-prop
    [ ] [ V{ } clone [ "specializations" set-word-prop ] keep ] ?if ;

M: vector-word subwords specializations values [ word? ] filter ;

: add-specialization ( new-word signature word -- )
    specializations set-at ;

: word-schema ( word -- schema ) vector-words at ;

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

: vector-words-for-type ( elt-type -- alist )
    {
        ! Can't do shifts on floats
        { [ dup float class<= ] [ vector-words keys { v<< v>> } diff ] }
        ! Can't divide integers
        { [ dup integer class<= ] [ vector-words keys { vsqrt n/v v/n v/ normalize } diff ] }
        [ { } ]
    } cond nip ;

:: specialize-vector-words ( array-type elt-type simd -- )
    elt-type vector-words-for-type [
        [ array-type elt-type simd specialize-vector-word ]
        [ array-type elt-type input-signature ]
        [ ]
        tri add-specialization
    ] each ;

: find-specialization ( classes word -- word/f )
    specializations
    [ first [ class<= ] 2all? ] with find
    swap [ second ] when ;

: vector-word-custom-inlining ( #call -- word/f )
    [ in-d>> [ value-info class>> ] map ] [ word>> ] bi
    find-specialization ;

vector-words keys [
    [ vector-word-custom-inlining ]
    "custom-inlining" set-word-prop
] each