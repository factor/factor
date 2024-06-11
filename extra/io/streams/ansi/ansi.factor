! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs destructors formatting io
io.streams.escape-codes io.streams.string io.styles kernel math
math.functions math.vectors namespaces sequences strings
terminfo ;

IN: io.streams.ansi

<PRIVATE

! N.b. the contents of the colormap are not standardized across terminals,
! although the order - KRGYBCMW - is. This map is a best-guess that should
! give good results on the majority of terminals, but it cannot be exact
! without adding significant complications to actively query the tty for
! colormap information.
CONSTANT: bg-colors
    H{
        ! Standard ANSI palette.
        { {   0   0   0 } { 40 } }
        { { 2/3   0   0 } { 41 } }
        { {   0 2/3   0 } { 42 } }
        { { 2/3 1/3   0 } { 43 } }
        { {   0   0 2/3 } { 44 } }
        { { 2/3   0 2/3 } { 45 } }
        { {   0 2/3 2/3 } { 46 } }
        { { 2/3 2/3 2/3 } { 47 } }

        ! AIXterm palette; bright versions of the ANSI colours.
        ! We assume that any colour terminal supports these.
        { { 1/3 1/3 1/3 } { 100 } }
        { {   1 1/3 1/3 } { 101 } }
        { { 1/3   1 1/3 } { 102 } }
        { {   1   1 1/3 } { 103 } }
        { { 1/3 1/3   1 } { 104 } }
        { {   1 1/3   1 } { 105 } }
        { { 1/3   1   1 } { 106 } }
        { {   1   1   1 } { 107 } }
    }

MEMO: fg-colors ( use-dim -- colormap )
    bg-colors [
        [ rest ]
        [ first 10 - ]
        bi prefix
    ] map-values swap
    [
        H{
            ! "Halfbright" palette, created by combining SGR2 (dim text)
            ! with the ANSI palette. Only usable for the foreground.
            ! If use-dim is enabled, we add these entries to the FG palette
            ! so we can get closer matches for them.
            { { 2/5   0   0 } { 31 2 } }
            { {   0 2/5   0 } { 32 2 } }
            { { 2/5 1/5   0 } { 33 2 } }
            { {   0   0 2/5 } { 34 2 } }
            { { 2/5   0 2/5 } { 35 2 } }
            { {   0 2/5 2/5 } { 36 2 } }
            { { 2/5 2/5 2/5 } { 37 2 } }
        } assoc-union
    ] when ;

: color>rgb ( color -- rgb )
    [ red>> ] [ green>> ] [ blue>> ] tri 3array ;

: color>ansi ( color palette -- ansi )
    [ color>rgb '[ _ distance ] ] dip
    [ keys swap minimum-by ] [ at ] bi
    [ "%d" sprintf ] map ";" join "\e[" "m" surround ;

TUPLE: ansi < filter-writer fg bg ;

C: <ansi> ansi

MEMO: color>foreground ( color stream -- string )
    fg>> color>ansi ;

MEMO: color>background ( color stream -- string )
    bg>> color>ansi ;

M:: ansi stream-format ( str style stream -- )
    stream stream>> :> out
    style foreground of [ stream color>foreground out stream-write t ] [ f ] if*
    style background of [ stream color>background out stream-write drop t ] when*
    style font-style of [ ansi-font-style out stream-write drop t ] when*
    str out stream-write
    [ "\e[0m" out stream-write ] when ;

M: ansi make-span-stream
    swap <style-stream> <ignore-close-stream> ;

M: ansi make-block-stream
    swap <style-stream> <ignore-close-stream> ;

M: ansi stream-write-table
    [
        drop
        [ [ stream>> >string ] map ] map format-ansi-table
        [ nl ] [ write ] interleave
    ] with-output-stream* ;

M: ansi make-cell-stream
    nip [ drop <string-writer> ] [ fg>> ] [ bg>> ] tri <ansi> ;

M: ansi dispose drop ;

PRIVATE>

: (with-ansi) ( quot use-dim -- )
    [ output-stream get ] dip fg-colors bg-colors <ansi> swap with-output-stream* ; inline

! We gate the use of the dim attribute on whether the tty supports it. Note
! however that some terminals (such as kmscon) claim to support this attribute
! but do not.
: with-ansi ( quot -- )
    tty-supports-dim? (with-ansi) ; inline
