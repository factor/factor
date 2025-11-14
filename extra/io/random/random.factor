! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: io io.files kernel math namespaces random sequences
sequences.private ;

IN: io.random

<PRIVATE

: each-numbered-line ( ... quot: ( ... line number -- ... ) -- ... )
    [ 1 ] dip '[ swap _ [ 1 + ] bi ] each-line drop ; inline

PRIVATE>

: random-line ( -- line/f )
    f random-generator get '[
        _ random* zero? [ nip ] [ drop ] if
    ] each-numbered-line ;

:: random-lines ( n -- lines )
    V{ } clone :> accum
    random-generator get :> rnd
    [| line line# |
        line# n <= [
            line accum push
        ] [
            line# rnd random* :> r
            r n < [ line r accum set-nth-unsafe ] when
        ] if
    ] each-numbered-line accum ;

: random-file-line ( path encoding -- line/f )
    [ random-line ] with-file-reader ; inline

: random-file-lines ( path encoding n -- lines )
    '[ _ random-lines ] with-file-reader ; inline
