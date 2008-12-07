! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs circular combinators continuations hashtables
hashtables.private io kernel math namespaces prettyprint
quotations sequences splitting state-parser strings ;
IN: html.parser.utils

: string-parse-end? ( -- ? ) get-next not ;

: take-string* ( match -- string )
    dup length <circular-string>
    [ 2dup string-matches? ] take-until nip
    dup length rot length 1- - head next* ;

: trim1 ( seq ch -- newseq )
    [ ?head drop ] [ ?tail drop ] bi ;

: single-quote ( str -- newstr )
    "'" dup surround ;

: double-quote ( str -- newstr )
    "\"" dup surround ;

: quote ( str -- newstr )
    CHAR: ' over member?
    [ double-quote ] [ single-quote ] if ;

: quoted? ( str -- ? )
    [ f ]
    [ [ first ] [ peek ] bi [ = ] keep "'\"" member? and ] if-empty ;

: ?quote ( str -- newstr )
    dup quoted? [ quote ] unless ;

: unquote ( str -- newstr )
    dup quoted? [ but-last-slice rest-slice >string ] when ;

: quote? ( ch -- ? ) "'\"" member? ;
