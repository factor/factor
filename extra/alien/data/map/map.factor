! Copyright (C) 2009, 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.arrays alien.c-types alien.data
alien.parser arrays byte-arrays combinators effects.parser fry
generalizations grouping kernel make math sequences
sequences.generalizations sequences.private ;
FROM: alien.arrays => array-length ;
IN: alien.data.map

<PRIVATE

: <displaced-direct-array> ( displacement bytes length type -- direct-array )
    [ <displaced-alien> ] 2dip <c-direct-array> ; inline

TUPLE: data-map-param
    { c-type read-only }
    { count fixnum read-only }
    { orig read-only }
    { bytes c-ptr read-only }
    { byte-length fixnum read-only }
    { iter-length fixnum read-only }
    { iter-count fixnum read-only } ;

M: data-map-param length
    iter-count>> ; inline

M: data-map-param nth-unsafe
    {
        [ iter-length>> * >fixnum ]
        [ bytes>> ]
        [ count>> ]
        [ c-type>> ]
    } cleave <displaced-direct-array> ; inline

INSTANCE: data-map-param immutable-sequence

: c-type-count ( in/out -- c-type count )
    dup array? [ unclip swap array-length >fixnum ] [ 1 ] if ; inline

: c-type-iter-length ( c-type count -- iter-length )
    swap heap-size * >fixnum ; inline

: [>c-type-param] ( c-type count -- quot )
    2dup c-type-iter-length '[
        [ _ _ ] dip
        [ ]
        [ >c-ptr ]
        [ byte-length ] tri
        _
        2dup /i
        data-map-param boa
    ] ;

: [>object-param] ( class count -- quot )
    nip '[ _ <groups> ] ;

: [>param] ( type -- quot )
    c-type-count over c-type-name?
    [ [>c-type-param] ] [ [>object-param] ] if ;

MACRO: >param ( in -- quot: ( array -- param ) )
    [>param] ;

: [alloc-c-type-param] ( c-type count -- quot )
    2dup c-type-iter-length dup '[
        [ _ _ ] dip
        [
            _ * >fixnum [ (byte-array) dup ] keep
            _
        ] keep
        data-map-param boa
    ] ;

: [alloc-object-param] ( type count -- quot )
    "Factor sequences as data-map outputs not supported" throw ;

: [alloc-param] ( type -- quot )
    c-type-count over c-type-name?
    [ [alloc-c-type-param] ] [ [alloc-object-param] ] if ;

MACRO: alloc-param ( out -- quot: ( len -- param ) )
    [alloc-param] ;

MACRO: unpack-params ( ins -- quot )
    [ c-type-count nip '[ _ firstn-unsafe ] ] map '[ _ spread ] ;

MACRO: pack-params ( outs -- quot )
    [ ] [ c-type-count nip dup
    [ [ ndip POSTPONE: _ ] dip set-firstn ] 3curry ] reduce
    fry [ call ] compose ;

:: [data-map] ( ins outs param-quot -- quot )
    ins length :> #ins
    outs length :> #outs
    #ins #outs + :> #params

    [
        param-quot %
        [
            [
                [ ins , \ unpack-params , \ @ , ] [ ] make ,
                #outs , \ ndip , outs , \ pack-params ,
            ] [ ] make ,
            #params , \ neach ,
        ] [ ] make , #outs , \ nkeep ,
        [ orig>> ] , #outs , \ napply ,
    ] [ ] make fry \ call suffix ;

MACRO: data-map ( ins outs -- quot )
    2dup
    [
        [ [ '[ _ >param ] ] map '[ _ spread ] ]
        [ length dup '[ _ ndup _ nmin-length ] compose ] bi
    ]
    [ [ '[ _ alloc-param ] ] map '[ _ cleave ] ] bi* compose
    [data-map] ;

MACRO: data-map! ( ins outs -- quot )
    2dup append [ '[ _ >param ] ] map '[ _ spread ] [data-map] ;

: parse-data-map-effect ( accum -- accum )
    ")" parse-effect
    [ in>>  [ (parse-c-type) ] map suffix! ]
    [ out>> [ (parse-c-type) ] map suffix! ] bi ;

PRIVATE>

SYNTAX: data-map(
    parse-data-map-effect \ data-map suffix! ;

SYNTAX: data-map!(
    parse-data-map-effect \ data-map! suffix! ;
