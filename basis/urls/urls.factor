! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs classes combinators
combinators.short-circuit fry hashtables io.encodings.string
io.encodings.utf8 io.sockets kernel lexer make math math.parser
namespaces parser peg.ebnf present sequences splitting strings
strings.parser urls.encoding ;
IN: urls

TUPLE: url protocol username password addr path query anchor ;

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

ERROR: malformed-port ;

: parse-host ( string -- host/f port/f )
    [
        ":" split1-last [ url-decode ]
        [ dup [ string>number [ malformed-port ] unless* ] when ] bi*
    ] [ f f ] if* ;

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
    [ <url> ] dip
    parse-url {
        [
            first [
                [ first >>protocol ]
                [
                    second
                    [ first [ first2 [ >>username ] [ >>password ] bi* ] when* ]
                    [ second parse-host <inet> >>addr ] bi
                ] bi
            ] when*
        ]
        [ second >>path ]
        [ third >>query ]
        [ fourth >>anchor ]
    } cleave
    dup addr>> [ [ "/" or ] change-path ] when ;

<PRIVATE

: inet>url ( inet -- url ) [ <url> ] dip >>addr ;

PRIVATE>

M: inet >url inet>url ;
M: inet4 >url inet>url ;
M: inet6 >url inet>url ;

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
    [ addr>> port>> ]
    [ addr>> port>> ]
    [ protocol>> protocol-port ] tri =
    [ drop f ] when ;

: unparse-host-part ( url protocol -- )
    %
    "://" %
    {
        [ unparse-username-password ]
        [ addr>> host>> url-encode % ]
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
        [ [ "/" split1-last drop "/" ] dip 3append ]
    } cond ;

PRIVATE>

: derive-url ( base url -- url' )
    [ clone ] dip over {
        [ [ protocol>>  ] either? >>protocol ]
        [ [ username>>  ] either? >>username ]
        [ [ password>>  ] either? >>password ]
        [ [ addr>>      ] either? >>addr ]
        [ [ path>>      ] bi@ swap url-append-path >>path ]
        [ [ query>>     ] either? >>query ]
        [ [ anchor>>    ] either? >>anchor ]
    } 2cleave ;

: relative-url ( url -- url' )
    clone
        f >>protocol
        f >>addr ;

: relative-url? ( url -- ? ) protocol>> not ;

! Half-baked stuff follows
: secure-protocol? ( protocol -- ? )
    "https" = ;

<PRIVATE

GENERIC: >secure-addr ( addrspec -- addrspec' )

PRIVATE>

: url-addr ( url -- addr )
    [
        [ addr>> ]
        [ [ addr>> port>> ] [ protocol>> protocol-port ] bi or ] bi with-port
    ] [ protocol>> ] bi
    secure-protocol? [ >secure-addr ] when ;

: ensure-port ( url -- url' )
    clone dup protocol>> '[
        dup port>> _ protocol-port or with-port
    ] change-addr ;

! Literal syntax
SYNTAX: URL" lexer get skip-blank parse-string >url suffix! ;

USE: vocabs.loader

{ "urls" "prettyprint" } "urls.prettyprint" require-when
