! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs destructors formatting fry io
io.streams.string io.styles kernel math math.functions
math.vectors namespaces sequences strings strings.tables ;

IN: io.streams.ansi

<PRIVATE

CONSTANT: colors H{

    ! System colors (8 colors)
    { {   0   0   0 } 0 }
    { { 170   0   0 } 1 }
    { {   0 170   0 } 2 }
    { { 170  85   0 } 3 }
    { {   0   0 170 } 4 }
    { { 170   0 170 } 5 }
    { {   0 170 170 } 6 }
    { { 170 170 170 } 7 }

    ! "Bright" version of 8 colors
    { {  85  85  85 } 8 }
    { { 255  85  85 } 9 }
    { {  85 255  85 } 10 }
    { { 255 255  85 } 11 }
    { {  85  85 255 } 12 }
    { { 255  85 255 } 13 }
    { {  85 255 255 } 14 }
    { { 255 255 255 } 15 }
}

: color>rgb ( color -- rgb )
    [ red>> ] [ green>> ] [ blue>> ] tri
    [ 255 * round >integer ] tri@ 3array ;

: color>ansi ( color -- ansi bold? )
    color>rgb '[ _ distance ]
    colors [ keys swap infimum-by ] [ at ] bi
    dup 8 >= [ 8 - t ] [ f ] if ;

: color>foreground ( color -- string )
    color>ansi [ 30 + ] [ "m" ";1m" ? ] bi* "\e[%d%s" sprintf ;

: color>background ( color -- string )
    color>ansi [ 40 + ] [ "m" ";1m" ? ] bi* "\e[%d%s" sprintf ;

: font-styles ( font-style -- string )
    H{
        { bold "\e[1m" }
        { italic "\e[3m" }
        { bold-italic "\e[1m\e[3m" }
    } at "" or ;

TUPLE: ansi stream ;

C: <ansi> ansi

M: ansi stream-write1 stream>> stream-write1 ;
M: ansi stream-write stream>> stream-write ;
M: ansi stream-flush stream>> stream-flush ;
M: ansi stream-nl stream>> stream-nl ;

M: ansi stream-format
    [
        [ foreground of [ color>foreground ] [ "" ] if* ]
        [ background of [ color>background ] [ "" ] if* ]
        [ font-style of [ font-styles ] [ "" ] if* ]
        tri 3append [ "\e[0m" surround ] unless-empty
    ] dip stream>> stream-write ;

M: ansi make-span-stream
    swap <style-stream> <ignore-close-stream> ;

M: ansi make-block-stream
    swap <style-stream> <ignore-close-stream> ;

! FIXME: color codes take up formatting space

M: ansi stream-write-table
    [
        drop
        [ [ stream>> >string ] map ] map format-table
        [ nl ] [ write ] interleave
    ] with-output-stream* ;

M: ansi make-cell-stream
     2drop <string-writer> <ansi> ;

M: ansi dispose drop ;

PRIVATE>

: with-ansi ( quot -- )
    output-stream get <ansi> swap with-output-stream* ; inline
