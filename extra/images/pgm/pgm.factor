! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types ascii combinators images
images.loader io io.encodings.ascii io.encodings.string
io.streams.throwing kernel make math math.parser sequences
specialized-arrays ;
SPECIALIZED-ARRAY: ushort
IN: images.pgm

SINGLETON: pgm-image
"pgm" pgm-image ?register-image-class

: read-token ( -- token )
    [ read1 dup blank?
      [ t ]
      [ dup CHAR: # =
        [ "\n" read-until 2drop t ]
        [ f ] if
      ] if
    ] [ drop ] while
    " \n\r\t" read-until drop swap
    prefix ascii decode ;

: read-number ( -- number )
    read-token string>number ;

:: read-numbers ( n lim -- )
    n lim = [
        read-number ,
        n 1 + lim read-numbers
    ] unless ;

:: read-pgm ( -- image )
    read-token         :> type
    read-number        :> width
    read-number        :> height
    read-number        :> max
    width height *     :> npixels
    max 256 >=         :> wide

    type {
        { "P2" [ [ 0 npixels read-numbers ] wide [ ushort-array{ } ] [ B{ } ] if make ] }
        { "P5" [ wide [ 2 ] [ 1 ] if npixels * read ] }
    } case :> data

    image new
    L                                                  >>component-order
    { width height }                                   >>dim
    f                                                  >>upside-down?
    data                                               >>bitmap
    wide [ ushort-components ] [ ubyte-components ] if >>component-type ;

M: pgm-image stream>image*
    drop [ [ read-pgm ] throw-on-eof ] with-input-stream ;

M: pgm-image image>stream
    2drop {
        [ drop "P5\n" ascii encode write ]
        [ dim>> first number>string " " append ascii encode write ]
        [ dim>> second number>string "\n" append ascii encode write ]
        [ component-type>> ubyte-components = [ "255\n" ] [ "65535\n" ] if ascii encode write ]
        [ bitmap>> write ]
    } cleave ;
