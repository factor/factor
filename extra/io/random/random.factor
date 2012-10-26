! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators destructors fry io io.encodings.binary
io.files io.streams.limited io.streams.random kernel locals
math math.order random sequences sequences.private ;

IN: io.random

<PRIVATE

: each-numbered-line ( ... quot: ( ... line number -- ... ) -- ... )
    [ 1 ] dip '[ swap [ @ ] [ 1 + ] bi ] each-line drop ; inline

PRIVATE>

: random-line ( -- line/f )
    f [ random zero? [ nip ] [ drop ] if ] each-numbered-line ;

:: random-lines ( n -- lines )
    V{ } clone :> accum
    [| line line# |
        line# n <= [
            line accum push
        ] [
            line# random :> r
            r n < [ line r accum set-nth-unsafe ] when
        ] if
    ] each-numbered-line accum ;

: random-file ( n path -- )
    [
        [ <random-stream> swap limit-stream ]
        [ binary <file-writer> ] bi*
        [ &dispose ] bi@ stream-copy
    ] with-destructors ;
