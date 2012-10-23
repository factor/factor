! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: fry io kernel locals math random sequences
sequences.extras ;

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
        line# random :> r
        r n < [
            line# n <=
            [ line r accum insert-nth! ]
            [ line r accum set-nth ] if
        ] when
    ] each-numbered-line accum ;
