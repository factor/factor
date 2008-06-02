! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel unicode.categories combinators sequences splitting
fry namespaces assocs arrays strings io.sockets
io.sockets.secure io.encodings.string io.encodings.utf8
math math.parser accessors mirrors parser
prettyprint.backend hashtables ;
IN: urls

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    {
        { [ dup letter? ] [ t ] }
        { [ dup LETTER? ] [ t ] }
        { [ dup digit? ] [ t ] }
        { [ dup "/_-.:" member? ] [ t ] }
        [ f ]
    } cond nip ; foldable

: push-utf8 ( ch -- )
    1string utf8 encode
    [ CHAR: % , >hex 2 CHAR: 0 pad-left % ] each ;

: url-encode ( str -- str )
    [
        [ dup url-quotable? [ , ] [ push-utf8 ] if ] each
    ] "" make ;

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        [ 1+ dup 2 + ] dip subseq  hex> [ , ] when*
    ] if ;

: url-decode-% ( index str -- index str )
    2dup url-decode-hex [ 3 + ] dip ;

: url-decode-+-or-other ( index str ch -- index str )
    dup CHAR: + = [ drop CHAR: \s ] when , [ 1+ ] dip ;

: url-decode-iter ( index str -- )
    2dup length >= [
        2drop
    ] [
        2dup nth dup CHAR: % = [
            drop url-decode-%
        ] [
            url-decode-+-or-other
        ] if url-decode-iter
    ] if ;

: url-decode ( str -- str )
    [ 0 swap url-decode-iter ] "" make utf8 decode ;

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

: query>assoc ( query -- assoc )
    dup [
        "&" split H{ } clone [
            [
                [ "=" split1 [ dup [ url-decode ] when ] bi@ swap ] dip
                add-query-param
            ] curry each
        ] keep
    ] when ;

: assoc>query ( hash -- str )
    [
        {
            { [ dup number? ] [ number>string 1array ] }
            { [ dup string? ] [ 1array ] }
            { [ dup sequence? ] [ ] }
        } cond
    ] assoc-map
    [
        [
            [ url-encode ] dip
            [ url-encode "=" swap 3append , ] with each
        ] assoc-each
    ] { } make "&" join ;

TUPLE: url protocol username password host port path query anchor ;

: <url> ( -- url ) url new ;

: query-param ( url key -- value )
    swap query>> at ;

: set-query-param ( url value key -- url )
    '[ , , _ ?set-at ] change-query ;

: parse-host ( string -- host port )
    ":" split1 [ url-decode ] [
        dup [
            string>number
            dup [ "Invalid port" throw ] unless
        ] when
    ] bi* ;

: parse-host-part ( url protocol rest -- url string' )
    [ >>protocol ] [
        "//" ?head [ "Invalid URL" throw ] unless
        "@" split1 [
            [
                ":" split1 [ >>username ] [ >>password ] bi*
            ] dip
        ] when*
        "/" split1 [
            parse-host [ >>host ] [ >>port ] bi*
        ] [ "/" prepend ] bi*
    ] bi* ;

GENERIC: >url ( obj -- url )

M: url >url ;

M: string >url
    <url> swap
    ":" split1 [ parse-host-part ] when*
    "#" split1 [
        "?" split1
        [ url-decode >>path ]
        [ [ query>assoc >>query ] when* ] bi*
    ]
    [ url-decode >>anchor ] bi* ;

: unparse-username-password ( url -- )
    dup username>> dup [
        % password>> [ ":" % % ] when* "@" %
    ] [ 2drop ] if ;

: unparse-host-part ( url protocol -- )
    %
    "://" %
    {
        [ unparse-username-password ]
        [ host>> url-encode % ]
        [ port>> [ ":" % # ] when* ]
        [ path>> "/" head? [ "/" % ] unless ]
    } cleave ;

: url>string ( url -- string )
    [
        {
            [ dup protocol>> dup [ unparse-host-part ] [ 2drop ] if ]
            [ path>> url-encode % ]
            [ query>> dup assoc-empty? [ drop ] [ "?" % assoc>query % ] if ]
            [ anchor>> [ "#" % url-encode % ] when* ]
        } cleave
    ] "" make ;

: url-append-path ( path1 path2 -- path )
    {
        { [ dup "/" head? ] [ nip ] }
        { [ dup empty? ] [ drop ] }
        { [ over "/" tail? ] [ append ] }
        { [ "/" pick start not ] [ nip ] }
        [ [ "/" last-split1 drop "/" ] dip 3append ]
    } cond ;

: derive-url ( base url -- url' )
    [ clone dup ] dip
    2dup [ path>> ] bi@ url-append-path
    [ [ <mirror> ] bi@ [ nip ] assoc-filter update ] dip
    >>path ;

: relative-url ( url -- url' )
    clone f >>protocol f >>host f >>port ;

! Half-baked stuff follows
: secure-protocol? ( protocol -- ? )
    "https" = ;

: url-addr ( url -- addr )
    [ [ host>> ] [ port>> ] bi <inet> ] [ protocol>> ] bi
    secure-protocol? [ <secure> ] when ;

: protocol-port ( protocol -- port )
    {
        { "http" [ 80 ] }
        { "https" [ 443 ] }
        { "ftp" [ 21 ] }
    } case ;

: ensure-port ( url -- url' )
    dup protocol>> '[ , protocol-port or ] change-port ;

! Literal syntax
: URL" lexer get skip-blank parse-string >url parsed ; parsing

M: url pprint* dup url>string "URL\" " "\"" pprint-string ;
