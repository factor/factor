! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
kernel math quotations sequences ;
IN: words.inlined

: inline-quotation? ( obj -- ? )
    {
        [ dup array? [ length>> 2 >= ] [ drop f ] if ]
        [ second quotation? ]
    } 1&& ;

: effect>inline-quotations ( effect -- quot/f )
    in>>
    [ dup inline-quotation? [ last ] [ drop [ ] ] if ] map
    dup [ length 0 > ] any? [ '[ _ spread ] ] [ drop f ] if ;

: apply-inlined-effects ( def effect -- def effect )
    dup effect>inline-quotations dup [
        swap [ prepose ] dip
    ] [
        drop
    ] if ;
