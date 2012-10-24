! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators fry io kernel locals math math.order random
sequences ;

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
        line# n <=> {
            { +lt+ [ line accum push ] }
            { +eq+ [ line accum [ push ] [ randomize drop ] bi ] }
            { +gt+ [ line# random :> r
                     r n < [ line r accum set-nth ] when ] }
        } case
    ] each-numbered-line accum ;
