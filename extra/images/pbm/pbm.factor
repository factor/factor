! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii bit-arrays byte-arrays combinators
continuations grouping images images.loader io
io.encodings.ascii io.encodings.string io.streams.throwing
kernel make math math.functions math.parser sequences ;
IN: images.pbm

SINGLETON: pbm-image
"pbm" pbm-image ?register-image-class

<PRIVATE
: read-token ( -- token )
    [
        read1 dup blank?
        [ t ]
        [
            dup CHAR: # =
            [ "\n" read-until 2drop t ]
            [ f ] if
        ] if
    ] [ drop ] while
    " \n\r\t" read-until drop swap
    prefix ascii decode ;

: read-number ( -- number )
    read-token string>number ;

: read-ascii-bits ( -- )
    read1 {
        { CHAR: 1 [ 0 , read-ascii-bits ] }
        { CHAR: 0 [ 255 , read-ascii-bits ] }
        { f [ ] }
        [ drop read-ascii-bits ]
    } case ;

:: read-binary-bits ( width height -- )
    width 8 align 8 / height * read
    width 8 align 8 / <groups> [| row |
        width <iota> [| n |
            n 8 / floor row nth
            n 8 mod 7 swap - bit?
            [ 0 ] [ 255 ] if ,
        ] each
    ] each ;

:: write-binary-bits ( bitmap width -- )
    bitmap width <groups> [
        width 8 align 255 pad-tail
        8 <groups> [
            [ 255 = not ] { } map-as
            >bit-array reverse bit-array>integer
            1array >byte-array write
        ] each
    ] each ;

:: read-pbm ( -- image )
    read-token     :> type
    read-number    :> width
    read-number    :> height

    type {
        { "P1" [ [ [ read-ascii-bits ] ignore-errors ] B{ } make ] }
        { "P4" [ [ width height read-binary-bits ] B{ } make ] }
    } case :> data

    image new
    L                >>component-order
    { width height } >>dim
    f                >>upside-down?
    data             >>bitmap
    ubyte-components >>component-type ;
PRIVATE>

M: pbm-image stream>image*
    drop [ [ read-pbm ] throw-on-eof ] with-input-stream ;

M: pbm-image image>stream
    2drop {
        [ drop "P4\n" ascii encode write ]
        [ dim>> first number>string " " append ascii encode write ]
        [ dim>> second number>string "\n" append ascii encode write ]
        [ [ bitmap>> ] [ dim>> first ] bi write-binary-bits ]
    } cleave ;
