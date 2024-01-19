! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: io io.files kernel math random sequences
sequences.private ;

IN: io.random

<PRIVATE

: each-numbered-line ( ... quot: ( ... line number -- ... ) -- ... )
    [ 1 ] dip '[ swap _ [ 1 + ] bi ] each-line drop ; inline

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

: random-file-line ( path encoding -- line/f )
    [ random-line ] with-file-reader ; inline

: random-file-lines ( path encoding n -- lines )
    '[ _ random-file-lines ] with-file-reader ; inline
