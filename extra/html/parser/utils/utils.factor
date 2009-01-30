! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs circular combinators continuations hashtables
hashtables.private io kernel math namespaces prettyprint
quotations sequences splitting html.parser.state strings
combinators.short-circuit ;
IN: html.parser.utils

: string-parse-end? ( -- ? ) get-next not ;

: trim1 ( seq ch -- newseq )
    [ [ ?head-slice drop ] [ ?tail-slice drop ] bi ] 2keep drop like ;

: quote? ( ch -- ? ) "'\"" member? ;

: single-quote ( str -- newstr ) "'" dup surround ;

: double-quote ( str -- newstr ) "\"" dup surround ;

: quote ( str -- newstr )
    CHAR: ' over member?
    [ double-quote ] [ single-quote ] if ;

: quoted? ( str -- ? )
    {
        [ length 1 > ]
        [ first quote? ]
        [ [ first ] [ peek ] bi = ]
    } 1&& ;

: ?quote ( str -- newstr ) dup quoted? [ quote ] unless ;

: unquote ( str -- newstr )
    dup quoted? [ but-last-slice rest-slice >string ] when ;
