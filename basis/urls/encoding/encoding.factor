! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii assocs byte-arrays combinators
combinators.short-circuit fry io.encodings.string
io.encodings.utf8 kernel linked-assocs make math math.parser
present sequences splitting strings ;
IN: urls.encoding

: url-quotable? ( ch -- ? )
    {
        [ letter? ]
        [ LETTER? ]
        [ digit? ]
        [ "-._~/:" member? ]
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

: hex% ( n -- )
    CHAR: % , >hex >upper 2 CHAR: 0 pad-head % ;

: push-utf8 ( ch -- )
    1string utf8 encode [ hex% ] each ;

: (url-encode) ( str quot: ( ch -- ? ) -- encoded )
    [
        over byte-sequence? [
            '[ dup @ [ , ] [ hex% ] if ] each
        ] [
            [ present ] dip
            '[ dup @ [ , ] [ push-utf8 ] if ] each
        ] if
    ] "" make ; inline

PRIVATE>

: url-encode ( obj -- encoded )
    [ url-quotable? ] (url-encode) ;

: url-encode-full ( obj -- encoded )
    [ unreserved? ] (url-encode) ;

<PRIVATE

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        [ 1 + dup 2 + ] dip subseq hex> [ , ] when*
    ] if ;

: url-decode-iter ( index str -- )
    2dup length >= [
        2drop
    ] [
        2dup nth dup CHAR: % = [
            drop 2dup url-decode-hex [ 3 + ] dip
        ] [
            , [ 1 + ] dip
        ] if url-decode-iter
    ] if ;

PRIVATE>

: url-decode ( str -- decoded )
    [ 0 swap url-decode-iter ] "" make utf8 decode ;

: query-decode ( str -- decoded )
    "+" split "%20" join url-decode ;

<PRIVATE

: add-query-param ( value key assoc -- )
    [
        {
            { [ dup string? ] [ swap 2array ] }
            { [ dup array? ] [ swap suffix ] }
            { [ dup not ] [ drop ] }
        } cond
    ] change-at ;

PRIVATE>

: query>assoc ( query -- assoc )
    dup [
        "&;" split <linked-hash> [
            [
                [ "=" split1 [ dup [ query-decode ] when ] bi@ swap ] dip
                add-query-param
            ] curry each
        ] keep
    ] when ;

: assoc>query ( assoc -- str )
    [
        [
            [ url-encode-full ] dip [
                dup array? [ 1array ] unless
                [ url-encode-full "=" glue , ] with each
            ] [ , ] if*
        ] assoc-each
    ] { } make "&" join ;
