! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii combinators images images.loader io
io.encodings.ascii io.encodings.string io.streams.throwing
kernel make math math.parser sequences ;
IN: images.ppm

SINGLETON: ppm-image
"ppm" ppm-image ?register-image-class

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

:: read-ppm ( -- image )
    read-token         :> type
    read-number        :> width
    read-number        :> height
    read-number        :> max
    width height 3 * * :> npixels
    type {
        { "P3" [ [ 0 npixels read-numbers ] B{ } make ] }
        { "P6" [ npixels read ] }
    } case :> data

    image new
    RGB              >>component-order
    { width height } >>dim
    f                >>upside-down?
    data             >>bitmap
    ubyte-components >>component-type ;

M: ppm-image stream>image*
    drop [ [ read-ppm ] throw-on-eof ] with-input-stream ;

M: ppm-image image>stream
    2drop {
        [ drop "P6\n" ascii encode write ]
        [ dim>> first number>string " " append ascii encode write ]
        [ dim>> second number>string "\n" append ascii encode write ]
        [ drop "255\n" ascii encode write ]
        [ bitmap>> write ]
    } cleave ;
