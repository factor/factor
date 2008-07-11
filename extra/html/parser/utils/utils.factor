USING: assocs circular combinators continuations hashtables
hashtables.private io kernel math
namespaces prettyprint quotations sequences splitting
state-parser strings sequences.lib ;
IN: html.parser.utils

: string-parse-end? ( -- ? )
    get-next not ;

: take-string* ( match -- string )
    dup length <circular-string>
    [ 2dup string-matches? ] take-until nip
    dup length rot length 1- - head next* ;

: trim1 ( seq ch -- newseq )
    [ ?head drop ] [ ?tail drop ] bi ;

: single-quote ( str -- newstr )
    >r "'" r> "'" 3append ;

: double-quote ( str -- newstr )
    >r "\"" r> "\"" 3append ;

: quote ( str -- newstr )
    CHAR: ' over member?
    [ double-quote ] [ single-quote ] if ;

: quoted? ( str -- ? )
    [ [ first ] [ peek ] bi [ = ] keep "'\"" member? and ] [ f ] if-seq ;

: ?quote ( str -- newstr )
    dup quoted? [ quote ] unless ;

: unquote ( str -- newstr )
    dup quoted? [ but-last-slice rest-slice >string ] when ;

: quote? ( ch -- ? ) "'\"" member? ;
