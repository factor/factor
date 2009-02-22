! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel math sequences strings ;
IN: quoting

: quote? ( ch -- ? ) "'\"" member? ;

: quoted? ( str -- ? )
    {
        [ length 1 > ]
        [ first quote? ]
        [ [ first ] [ peek ] bi = ]
    } 1&& ;

: unquote ( str -- newstr )
    dup quoted? [ but-last-slice rest-slice >string ] when ;
