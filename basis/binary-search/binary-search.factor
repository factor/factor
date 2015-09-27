! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators kernel locals math
math.order sequences sequences.private vectors ;
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
    over empty? [ 2drop f f ] [ [ 0 over length ] dip (search) ] if ; inline

GENERIC: natural-search ( obj seq -- i elt )
M: object natural-search [ <=> ] with search ;
M: array natural-search [ <=> ] with search ;
M: vector natural-search [ <=> ] with search ;

: sorted-index ( obj seq -- i )
    natural-search drop ;

: sorted-member? ( obj seq -- ? )
    dupd natural-search nip = ;

: sorted-member-eq? ( obj seq -- ? )
    dupd natural-search nip eq? ;
