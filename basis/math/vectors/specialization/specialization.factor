! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel make sequences effects kernel.private accessors
combinators math math.intervals math.vectors namespaces assocs fry
splitting classes.algebra generalizations
compiler.tree.propagation.info ;
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
    { v*n { +vector+ +scalar+ -> +vector+ } }
    { v+ { +vector+ +vector+ -> +vector+ } }
    { v+n { +vector+ +scalar+ -> +vector+ } }
    { v- { +vector+ +vector+ -> +vector+ } }
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
}

SYMBOL: specializations

specializations [ vector-words keys [ V{ } clone ] H{ } map>assoc ] initialize

: add-specialization ( new-word signature word -- )
    specializations get at set-at ;

: word-schema ( word -- schema ) vector-words at ;

: inputs ( schema -- seq ) { -> } split first ;

: outputs ( schema -- seq ) { -> } split second ;

: specialize-vector-word ( word array-type elt-type -- word' )
    pick word-schema
    [ inputs (specialize-vector-word) ]
    [ outputs record-output-signature ] 3bi ;

: input-signature ( word -- signature ) def>> first ;

: specialize-vector-words ( array-type elt-type -- )
    [ vector-words keys ] 2dip
    '[
        [ _ _ specialize-vector-word ] keep
        [ dup input-signature ] dip
        add-specialization
    ] each ;

: find-specialization ( classes word -- word/f )
    specializations get at
    [ first [ class<= ] 2all? ] with find
    swap [ second ] when ;

: vector-word-custom-inlining ( #call -- word/f )
    [ in-d>> [ value-info class>> ] map ] [ word>> ] bi
    find-specialization ;

vector-words keys [
    [ vector-word-custom-inlining ]
    "custom-inlining" set-word-prop
] each