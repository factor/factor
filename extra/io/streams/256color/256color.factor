! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs destructors environment
formatting fry io io.streams.string io.styles kernel locals
math math.functions math.ranges math.vectors namespaces
sequences sequences.extras strings strings.tables ;

IN: io.streams.256color

<PRIVATE

CONSTANT: intensities { 0x00 0x5F 0x87 0xAF 0xD7 0xFF }

CONSTANT: 256colors H{

    ! System colors (8 colors)
    { {   0   0   0 } 0 }
    { { 128   0   0 } 1 }
    { {   0 128   0 } 2 }
    { { 128 128   0 } 3 }
    { {   0   0 128 } 4 }
    { { 128   0 128 } 5 }
    { {   0 128 128 } 6 }
    { { 192 192 192 } 7 }

    ! "Bright" version of 8 colors
    { { 128 128 128 } 8 }
    { { 255   0   0 } 9 }
    { {   0 255   0 } 10 }
    { { 255 255   0 } 11 }
    { {   0   0 255 } 12 }
    { { 255   0 255 } 13 }
    { {   0 255 255 } 14 }
    { { 255 255 255 } 15 }
}

! Add the RGB colors
intensities [| r i |
    intensities [| g j |
        intensities [| b k |
            i 36 * j 6 * + k + 16 +
            r g b 3array
            256colors set-at
        ] each-index
    ] each-index
] each-index

! Add the Grayscale colors
0x08 0xee 10 <range> [
    [ dup dup 3array ] dip 232 + swap
    256colors set-at
] each-index

: color>rgb ( color -- rgb )
    [ red>> ] [ green>> ] [ blue>> ] tri
    [ 255 * round >integer ] tri@ 3array ;

: color>256color ( color -- 256color )
    color>rgb '[ _ distance ]
    256colors [ keys swap infimum-by ] [ at ] bi ;

: color>foreground ( color -- string )
    color>256color "\e[38;5;%sm" sprintf ;

: color>background ( color -- string )
    color>256color "\e[48;5;%sm" sprintf ;

: font-styles ( font-style -- string )
    H{
        { bold "\e[1m" }
        { italic "\e[3m" }
        { bold-italic "\e[1m\e[3m" }
    } at "" or ;

TUPLE: 256color stream ;

C: <256color> 256color

M: 256color stream-write1 stream>> stream-write1 ;
M: 256color stream-write stream>> stream-write ;
M: 256color stream-flush stream>> stream-flush ;
M: 256color stream-nl stream>> stream-nl ;

M: 256color stream-format
    [
        [ foreground of [ color>foreground ] [ "" ] if* ]
        [ background of [ color>background ] [ "" ] if* ]
        [ font-style of [ font-styles ] [ "" ] if* ]
        tri 3append [ "\e[0m" surround ] unless-empty
    ] dip stream>> stream-write ;

M: 256color make-span-stream
    swap <style-stream> <ignore-close-stream> ;

M: 256color make-block-stream
    swap <style-stream> <ignore-close-stream> ;

! FIXME: color codes take up formatting space

M: 256color stream-write-table
    [
        drop
        [ [ stream>> >string ] map ] map format-table
        [ nl ] [ write ] interleave
    ] with-output-stream* ;

M: 256color make-cell-stream
     2drop <string-writer> <256color> ;

M: 256color dispose drop ;

PRIVATE>

: 256color-terminal? ( -- ? )
    "TERM" os-env "-256color" tail? ;

: with-256color ( quot -- )
    output-stream get <256color> swap with-output-stream* ; inline
