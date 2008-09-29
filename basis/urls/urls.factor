! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ascii combinators combinators.short-circuit
sequences splitting fry namespaces make assocs arrays strings
io.sockets io.sockets.secure io.encodings.string
io.encodings.utf8 math math.parser accessors parser
strings.parser lexer prettyprint.backend hashtables present
peg.ebnf ;
IN: urls

: url-quotable? ( ch -- ? )
    {
        [ letter? ]
        [ LETTER? ]
        [ digit? ]
        [ "/_-.:" member? ]
    } 1|| ; foldable

<PRIVATE

: push-utf8 ( ch -- )
    dup CHAR: \s = [ drop "+" % ] [
        1string utf8 encode
        [ CHAR: % , >hex 2 CHAR: 0 pad-left % ] each
    ] if ;

PRIVATE>

: url-encode ( str -- encoded )
    [
        [ dup url-quotable? [ , ] [ push-utf8 ] if ] each
    ] "" make ;

<PRIVATE

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

PRIVATE>

: url-decode ( str -- decoded )
    [ 0 swap url-decode-iter ] "" make utf8 decode ;

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

PRIVATE>

: query>assoc ( query -- assoc )
    dup [
        "&" split H{ } clone [
            [
                [ "=" split1 [ dup [ url-decode ] when ] bi@ swap ] dip
                add-query-param
            ] curry each
        ] keep
    ] when ;

: assoc>query ( assoc -- str )
    [
        dup array? [ [ present ] map ] [ present 1array ] if
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

: delete-query-param ( url key -- url )
    over query>> delete-at ;

: set-query-param ( url value key -- url )
    over [
        '[ [ _ _ ] dip ?set-at ] change-query
    ] [
        nip delete-query-param
    ] if ;

: parse-host ( string -- host port )
    ":" split1 [ url-decode ] [
        dup [
            string>number
            dup [ "Invalid port" throw ] unless
        ] when
    ] bi* ;

GENERIC: >url ( obj -- url )

M: f >url drop <url> ;

M: url >url ;

<PRIVATE

EBNF: parse-url

protocol = [a-z]+                   => [[ url-decode ]]
username = [^/:@#?]+                => [[ url-decode ]]
password = [^/:@#?]+                => [[ url-decode ]]
pathname = [^#?]+                   => [[ url-decode ]]
query    = [^#]+                    => [[ query>assoc ]]
anchor   = .+                       => [[ url-decode ]]

hostname = [^/#?]+                  => [[ url-decode ]]

hostname-spec = hostname ("/"|!(.)) => [[ first ]]

auth     = (username (":" password  => [[ second ]])? "@"
                                    => [[ first2 2array ]])?

url      = ((protocol "://")        => [[ first ]] auth hostname)?
           (pathname)?
           ("?" query               => [[ second ]])?
           ("#" anchor              => [[ second ]])?

;EBNF

PRIVATE>

M: string >url
    parse-url {
        [
            first [
                [ first ] ! protocol
                [
                    second
                    [ first [ first2 ] [ f f ] if* ] ! username, password
                    [ second parse-host ] ! host, port
                    bi
                ] bi
            ] [ f f f f f ] if*
        ]
        [ second ] ! pathname
        [ third ] ! query
        [ fourth ] ! anchor
    } cleave url boa
    dup host>> [ [ "/" or ] change-path ] when ;

: protocol-port ( protocol -- port )
    {
        { "http" [ 80 ] }
        { "https" [ 443 ] }
        { "ftp" [ 21 ] }
        [ drop f ]
    } case ;

<PRIVATE

: unparse-username-password ( url -- )
    dup username>> dup [
        % password>> [ ":" % % ] when* "@" %
    ] [ 2drop ] if ;

: url-port ( url -- port/f )
    [ port>> ] [ port>> ] [ protocol>> protocol-port ] tri =
    [ drop f ] when ;

: unparse-host-part ( url protocol -- )
    %
    "://" %
    {
        [ unparse-username-password ]
        [ host>> url-encode % ]
        [ url-port [ ":" % # ] when* ]
        [ path>> "/" head? [ "/" % ] unless ]
    } cleave ;

PRIVATE>

M: url present
    [
        {
            [ dup protocol>> dup [ unparse-host-part ] [ 2drop ] if ]
            [ path>> url-encode % ]
            [ query>> dup assoc-empty? [ drop ] [ "?" % assoc>query % ] if ]
            [ anchor>> [ "#" % present url-encode % ] when* ]
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

PRIVATE>

: derive-url ( base url -- url' )
    [ clone ] dip over {
        [ [ protocol>> ] either? >>protocol ]
        [ [ username>> ] either? >>username ]
        [ [ password>> ] either? >>password ]
        [ [ host>>     ] either? >>host ]
        [ [ port>>     ] either? >>port ]
        [ [ path>>     ] bi@ swap url-append-path >>path ]
        [ [ query>>    ] either? >>query ]
        [ [ anchor>>   ] either? >>anchor ]
    } 2cleave ;

: relative-url ( url -- url' )
    clone
        f >>protocol
        f >>host
        f >>port ;

! Half-baked stuff follows
: secure-protocol? ( protocol -- ? )
    "https" = ;

: url-addr ( url -- addr )
    [
        [ host>> ]
        [ port>> ]
        [ protocol>> protocol-port ]
        tri or <inet>
    ] [ protocol>> ] bi
    secure-protocol? [ <secure> ] when ;

: ensure-port ( url -- url )
    dup protocol>> '[ _ protocol-port or ] change-port ;

! Literal syntax
: URL" lexer get skip-blank parse-string >url parsed ; parsing

M: url pprint* dup present "URL\" " "\"" pprint-string ;
