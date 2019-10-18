USING: assocs circular combinators continuations hashtables
hashtables.private io kernel math
namespaces prettyprint quotations sequences splitting
state-parser strings ;
USING: browser.parser ;
IN: browser.utils

: string-parse-end?
    get-next not ;

: take-string* ( match -- string )
    dup length <circular-string>
    [ 2dup string-matches? ] take-until nip
    dup length rot length 1- - head next* ;

: trim1 ( seq ch -- newseq )
    [ ?head drop ] keep ?tail drop ;

: single-quote ( str -- newstr )
    >r "'" r> "'" 3append ;

: double-quote ( str -- newstr )
    >r "\"" r> "\"" 3append ;

: quote ( str -- newstr )
    CHAR: ' over member?
    [ double-quote ] [ single-quote ] if ;

: quoted? ( str -- ? )
    dup length 1 > [
        [ first ] keep peek [ = ] keep "'\"" member? and
    ] [
        drop f
    ] if ;

: ?quote ( str -- newstr )
    dup quoted? [ quote ] unless ;

: unquote ( str -- newstr )
    dup quoted? [ 1 head-slice* 1 tail-slice >string ] when ;

: quote? ( ch -- ? ) "'\"" member? ;

