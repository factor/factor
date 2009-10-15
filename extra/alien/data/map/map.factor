! (c)Joe Groff bsd license
USING: accessors alien alien.c-types alien.data alien.parser arrays
byte-arrays combinators effects.parser fry generalizations kernel
lexer locals macros math math.ranges parser sequences sequences.private ;
IN: alien.data.map

ERROR: bad-data-map-input-length byte-length iter-size remainder ;

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

ERROR: bad-data-map-param param remainder ;

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

: c-type-count ( in/out -- c-type count iter-length )
    dup array? [ unclip swap product >fixnum ] [ 1 ] if
    2dup swap heap-size * >fixnum ; inline

MACRO:: >param ( in -- quot: ( array -- param ) )
    in c-type-count :> iter-length :> count :> c-type

    [
        [ c-type count ] dip
        [ ]
        [ >c-ptr ]
        [ byte-length ] tri
        iter-length
        2dup /i
        data-map-param boa
    ] ;

MACRO:: alloc-param ( out -- quot: ( len -- param ) )
    out c-type-count :> iter-length :> count :> c-type

    [
        [ c-type count ] dip
        [
            iter-length * >fixnum [ (byte-array) dup ] keep
            iter-length
        ] keep
        data-map-param boa
    ] ;

MACRO: unpack-params ( ins -- )
    [ c-type-count drop nip '[ _ firstn-unsafe ] ] map '[ _ spread ] ;

MACRO: pack-params ( outs -- )
    [ ] [ c-type-count drop nip dup [ [ ndip _ ] dip set-firstn ] 3curry ] reduce
    fry [ call ] compose ;

:: [data-map] ( ins outs param-quot -- quot )
    ins length :> #ins
    outs length :> #outs
    #ins #outs + :> #params

    [| quot |
        param-quot call
        [
            [ [ ins unpack-params quot call ] #outs ndip outs pack-params ]
            #params neach
        ] #outs nkeep
        [ orig>> ] #outs napply
    ] ;

MACRO: data-map ( ins outs -- )
    2dup
    [
        [ [ '[ _ >param ] ] map '[ _ spread ] ]
        [ length dup '[ _ ndup _ nmin-length ] compose ] bi
    ]
    [ [ '[ _ alloc-param ] ] map '[ _ cleave ] ] bi* compose
    [data-map] ;

MACRO: data-map! ( ins outs -- )
    2dup append [ '[ _ >param ] ] map '[ _ spread ] [data-map] ;

: parse-data-map-effect ( accum -- accum )
    ")" parse-effect
    [ in>>  [ parse-c-type ] map parsed ]
    [ out>> [ parse-c-type ] map parsed ] bi ;

PRIVATE>

SYNTAX: data-map(
    parse-data-map-effect \ data-map parsed ;

SYNTAX: data-map!(
    parse-data-map-effect \ data-map! parsed ;

