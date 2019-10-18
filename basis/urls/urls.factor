! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ascii combinators combinators.short-circuit
sequences splitting fry namespaces make assocs arrays strings
io.sockets io.encodings.string io.encodings.utf8 math
math.parser accessors parser strings.parser lexer
hashtables present peg.ebnf urls.encoding ;
IN: urls

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
                    [ second parse-host [ >>host ] [ >>port ] bi* ] bi
                ] bi
            ] when*
        ]
        [ second >>path ]
        [ third >>query ]
        [ fourth >>anchor ]
    } cleave
    dup host>> [ [ "/" or ] change-path ] when ;

: protocol-port ( protocol -- port )
    {
        { "http" [ 80 ] }
        { "https" [ 443 ] }
        { "ftp" [ 21 ] }
        [ drop f ]
    } case ;

: relative-url ( url -- url' )
    clone
        f >>protocol
        f >>host
        f >>port ;

: relative-url? ( url -- ? ) protocol>> not ;

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

M: url present
    [
        {
            [ dup protocol>> dup [ unparse-host-part ] [ 2drop ] if ]
            [ path>> url-encode % ]
            [ query>> dup assoc-empty? [ drop ] [ "?" % assoc>query % ] if ]
            [ anchor>> [ "#" % present url-encode % ] when* ]
        } cleave
    ] "" make ;

PRIVATE>

: url-append-path ( path1 path2 -- path )
    {
        { [ dup "/" head? ] [ nip ] }
        { [ dup empty? ] [ drop ] }
        { [ over "/" tail? ] [ append ] }
        { [ "/" pick start not ] [ nip ] }
        [ [ "/" split1-last drop "/" ] dip 3append ]
    } cond ;

<PRIVATE

: derive-port ( url base -- url' )
    over relative-url? [ [ port>> ] either? ] [ drop port>> ] if ;

: derive-path ( url base -- url' )
    [ path>> ] bi@ swap url-append-path ;

PRIVATE>

: derive-url ( base url -- url' )
    [ clone ] dip over {
        [ [ protocol>>  ] either? >>protocol ]
        [ [ username>>  ] either? >>username ]
        [ [ password>>  ] either? >>password ]
        [ [ host>>      ] either? >>host ]
        [ derive-port             >>port ]
        [ derive-path             >>path ]
        [ [ query>>     ] either? >>query ]
        [ [ anchor>>    ] either? >>anchor ]
    } 2cleave ;

! Half-baked stuff follows
: secure-protocol? ( protocol -- ? )
    "https" = ;

<PRIVATE

GENERIC: >secure-addr ( addrspec -- addrspec' )

PRIVATE>

: url-addr ( url -- addr )
    [
        [ host>> ]
        [ port>> ]
        [ protocol>> protocol-port ]
        tri or <inet>
    ] [ protocol>> ] bi
    secure-protocol? [ >secure-addr ] when ;

: set-url-addr ( url addr -- url )
    [ host>> >>host ] [ port>> >>port ] bi ;

: ensure-port ( url -- url' )
    clone dup protocol>> '[ _ protocol-port or ] change-port ;

! Literal syntax
SYNTAX: URL" lexer get skip-blank parse-string >url suffix! ;

USE: vocabs.loader

{ "urls" "prettyprint" } "urls.prettyprint" require-when
{ "urls" "io.sockets.secure" } "urls.secure" require-when
