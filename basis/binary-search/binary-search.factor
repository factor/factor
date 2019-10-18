! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators hints kernel locals math
math.order sequences sequences.private ;
IN: binary-search

<PRIVATE

:: (search) ( seq from to quot: ( elt -- <=> ) -- i elt )
    from to + 2/ :> midpoint@
    midpoint@ seq nth-unsafe :> midpoint

    to from - 1 <= [
        midpoint@ midpoint
    ] [
        midpoint quot call {
            { +lt+ [ seq from midpoint@ quot (search) ] }
            { +gt+ [ seq midpoint@ to quot (search) ] }
            { +eq+ [ midpoint@ midpoint ] }
        } case
    ] if ; inline recursive

PRIVATE>

: search ( seq quot: ( elt -- <=> ) -- i elt )
    over empty? [ 2drop f f ] [ [ 0 over length ] dip (search) ] if ;
    inline

: natural-search ( obj seq -- i elt )
    [ <=> ] with search ;

HINTS: natural-search array ;

: sorted-index ( obj seq -- i )
    natural-search drop ;

: sorted-member? ( obj seq -- ? )
    dupd natural-search nip = ;

: sorted-member-eq? ( obj seq -- ? )
    dupd natural-search nip eq? ;
