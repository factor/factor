! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: sequences math kernel strings combinators.short-circuit ;
IN: quoting

: quote? ( ch -- ? ) "'\"" member? ;

: quoted? ( str -- ? )
    {
        [ length 1 > ]
        [ first quote? ]
        [ [ first ] [ last ] bi = ]
    } 1&& ;

: unquote ( str -- newstr )
    dup quoted? [ but-last-slice rest-slice >string ] when ;
