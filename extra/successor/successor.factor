! Copyright (C) 2011 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: ascii combinators combinators.short-circuit kernel
math sequences ;

IN: successor

<PRIVATE

: carry ( elt last first -- ? elt' )
    '[ _ > dup _ ] keep ? ;

: next-digit ( ch -- ? ch' )
    1 + CHAR: 9 CHAR: 0 carry ;

: next-letter ( ch -- ? ch' )
    [ ch>lower 1 + CHAR: z CHAR: a carry ] [ LETTER? ] bi
    [ ch>upper ] when ;

: next-char ( ch -- ? ch' )
    {
        { [ dup digit?  ] [ next-digit  ] }
        { [ dup Letter? ] [ next-letter ] }
        [ t swap ]
    } cond ;

: map-until ( seq quot: ( elt -- ? elt' ) -- seq' ? )
    [ t 0 pick length '[ 2dup _ < and ] ] dip '[
        nip [ over _ change-nth ] keep 1 +
    ] while drop ; inline

: alphanum? ( ch -- ? )
    { [ Letter? ] [ digit? ] } 1|| ;

PRIVATE>

: successor ( str -- str' )
    dup empty? [
        dup [ alphanum? ] any? [
            reverse [ next-char ] map-until
            [ dup last suffix ] when reverse
        ] [
            dup length 1 - over [ 1 + ] change-nth
        ] if
    ] unless ;
