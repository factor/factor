! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ascii combinators combinators.short-circuit
sequences splitting fry namespaces make assocs arrays strings
io.encodings.string io.encodings.utf8 math math.parser accessors
hashtables present ;
IN: urls.encoding

: url-quotable? ( ch -- ? )
    {
        [ letter? ]
        [ LETTER? ]
        [ digit? ]
        [ "/_-.:" member? ]
    } 1|| ; foldable

! see http://tools.ietf.org/html/rfc3986#section-2.2
: gen-delim? ( ch -- ? )
    ":/?#[]@" member? ; foldable

: sub-delim? ( ch -- ? )
    "!$&'()*+,;=" member? ; foldable

: reserved? ( ch -- ? )
    [ gen-delim? ] [ sub-delim? ] bi or ; foldable

! see http://tools.ietf.org/html/rfc3986#section-2.3
: unreserved? ( ch -- ? )
    {
        [ letter? ]
        [ LETTER? ]
        [ digit? ]
        [ "-._~" member? ]
    } 1|| ; foldable

<PRIVATE

: push-utf8 ( ch -- )
    1string utf8 encode
    [ CHAR: % , >hex 2 CHAR: 0 pad-head % ] each ;

PRIVATE>

: url-encode ( str -- encoded )
    [
        [ dup url-quotable? [ , ] [ push-utf8 ] if ] each
    ] "" make ;

: url-encode-full ( str -- encoded )
    [
        [ dup unreserved? [ , ] [ push-utf8 ] if ] each
    ] "" make ;

<PRIVATE

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        [ 1+ dup 2 + ] dip subseq  hex> [ , ] when*
    ] if ;

: url-decode-% ( index str -- index str )
    2dup url-decode-hex ;

: url-decode-iter ( index str -- )
    2dup length >= [
        2drop
    ] [
        2dup nth dup CHAR: % = [
            drop url-decode-% [ 3 + ] dip
        ] [
            , [ 1+ ] dip
        ] if url-decode-iter
    ] if ;

PRIVATE>

: url-decode ( str -- decoded )
    [ 0 swap url-decode-iter ] "" make utf8 decode ;

: query-decode ( str -- decoded )
    [ dup CHAR: + = [ drop "%20" ] [ 1string ] if ] { } map-as
    concat url-decode ;

<PRIVATE

: add-query-param ( value key assoc -- )
    [
        at [
            {
                { [ dup string? ] [ swap 2array ] }
                { [ dup array? ] [ swap suffix ] }
                { [ dup not ] [ drop ] }
            } cond
        ] when*
    ] 2keep set-at ;

: assoc-strings ( assoc -- assoc' )
    [
        {
            { [ dup not ] [ ] }
            { [ dup array? ] [ [ present ] map ] }
            [ present 1array ]
        } cond
    ] assoc-map ;

PRIVATE>

: query>assoc ( query -- assoc )
    dup [
        "&;" split H{ } clone [
            [
                [ "=" split1 [ dup [ query-decode ] when ] bi@ swap ] dip
                add-query-param
            ] curry each
        ] keep
    ] when ;

: assoc>query ( assoc -- str )
    [
        assoc-strings [
            [ url-encode ] dip
            [ [ url-encode "=" glue , ] with each ] [ , ] if*
        ] assoc-each
    ] { } make "&" join ;
