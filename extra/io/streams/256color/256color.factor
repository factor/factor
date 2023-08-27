! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators destructors
environment formatting io io.streams.escape-codes
io.streams.string io.styles kernel math math.functions
math.order namespaces ranges sequences sorting strings
strings.tables ;

IN: io.streams.256color

<PRIVATE

CONSTANT: intensities { 0x00 0x5F 0x87 0xAF 0xD7 0xFF }

CONSTANT: 256colors H{ }

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

: 256colors. ( -- )
    256colors sort-values [
        dup dup "\e[1;38;5;%sm%3s:\e[0m " printf
        dup rot first3 "\e[38;5;%sm#%02x%02x%02x\e[0m " printf
        6 mod 3 = [ nl ] when
    ] assoc-each ;

: color>rgb ( color -- r g b )
    [ red>> ] [ green>> ] [ blue>> ] tri
    [ 255 * round >integer ] tri@ ;

: gray? ( r g b -- ? )
    [ max max ] [ min min ] 3bi - 8 < ;

:: rgb>gray ( r g b -- color )
    {
        { [ r 0 4 between? ] [ 16 ] }
        { [ r 5 8 between? ] [ 232 ] }
        { [ r 238 246 between? ] [ 255 ] }
        { [ r 247 255 between? ] [ 231 ] }
        [ r 8 - 10 /i 232 + ]
    } cond ;

: rgb>256color ( r g b -- color )
    [ 55 - 40 /f 0 max round ] tri@
    [ 36 * ] [ 6 * + ] [ + ] tri* 16 + >integer ;

: color>256color ( color -- 256color )
    color>rgb 3dup gray? [ rgb>gray ] [ rgb>256color ] if ;

: color>foreground ( color -- string )
    color>256color "\e[38;5;%sm" sprintf ;

: color>background ( color -- string )
    color>256color "\e[48;5;%sm" sprintf ;

TUPLE: 256color < filter-writer ;

C: <256color> 256color

M:: 256color stream-format ( str style stream -- )
    stream stream>> :> out
    style foreground of [ color>foreground out stream-write t ] [ f ] if*
    style background of [ color>background out stream-write drop t ] when*
    style font-style of [ font-styles out stream-write drop t ] when*
    str out stream-write
    [ "\e[0m" out stream-write ] when ;

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
