! Copyright (C) 2007, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays byte-arrays columns
combinators compression.run-length endian fry grouping images
images.loader images.normalization io io.binary
io.encodings.binary io.encodings.string io.files
io.streams.limited kernel locals macros math math.bitwise
math.functions namespaces sequences specialized-arrays
specialized-arrays.instances.uint
specialized-arrays.instances.ushort strings summary ;
IN: images.bitmap

SINGLETON: bmp-image
"bmp" bmp-image register-image-class

: write2 ( n -- ) 2 >le write ;
: write4 ( n -- ) 4 >le write ;

: output-width-and-height ( image -- )
    [ dim>> first write4 ]
    [
        [ dim>> second ] [ upside-down?>> ] bi
        [ neg ] unless write4
    ] bi ;

: output-bmp ( image -- )
    B{ CHAR: B CHAR: M } write
    [
        bitmap>> length 14 + 40 + write4
        0 write4
        54 write4
        40 write4
    ] [
        {
            [ output-width-and-height ]

            ! planes
            [ drop 1 write2 ]

            ! bit-count
            [ drop 24 write2 ]

            ! compression
            [ drop 0 write4 ]

            ! image-size
            [ bitmap>> length write4 ]

            ! x-pels
            [ drop 0 write4 ]

            ! y-pels
            [ drop 0 write4 ]

            ! color-used
            [ drop 0 write4 ]

            ! color-important
            [ drop 0 write4 ]

            ! color-palette
            [ bitmap>> write ]
        } cleave
    ] bi ;

M: bmp-image image>stream
    drop BGR reorder-components output-bmp ;

