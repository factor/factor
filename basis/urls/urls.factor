! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs combinators fry io.pathnames
io.sockets io.sockets.secure kernel lexer linked-assocs make
math.parser namespaces peg.ebnf present sequences splitting
strings strings.parser urls.encoding vocabs.loader multiline ;
IN: urls

TUPLE: url protocol username password host port path query anchor ;

: <url> ( -- url ) url new ;

: query-param ( url key -- value )
    swap query>> at ;

: set-or-delete ( value key query -- )
    pick [ set-at ] [ delete-at drop ] if ;

: set-query-param ( url value key -- url )
    pick query>> [ <linked-hash> ] unless* [ set-or-delete ] keep >>query ;

: set-query-params ( url params -- url )
    [ swap set-query-param ] assoc-each ;

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

EBNF: parse-url [=[

protocol = [a-zA-Z0-9.+-]+          => [[ url-decode ]]
username = [^/:@#?]+                => [[ url-decode ]]
password = [^/:@#?]+                => [[ url-decode ]]
pathname = [^#?]+                   => [[ url-decode ]]
query    = [^#]+                    => [[ query>assoc ]]
anchor   = .+                       => [[ url-decode ]]

hostname = [^/#?]+                  => [[ url-decode ]]

hostname-spec = hostname ("/"|!(.)) => [[ first ]]

auth     = (username (":" password  => [[ second ]])? "@"
                                    => [[ first2 2array ]])?

url      = (((protocol "://") => [[ first ]] auth hostname)
                    | (("//") => [[ f ]] auth hostname))?
           (pathname)?
           ("?" query               => [[ second ]])?
           ("#" anchor              => [[ second ]])?

]=]

PRIVATE>

M: string >url
    [ <url> ] dip
    parse-url {
        [
            first [
                [ first >lower >>protocol ]
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

M: pathname >url string>> >url ;

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

: unparse-host-part ( url -- )
    {
        [ unparse-username-password ]
        [ host>> url-encode % ]
        [ url-port [ ":" % # ] when* ]
        [ path>> "/" head? [ "/" % ] unless ]
    } cleave ;

! URL" //foo.com" takes on the protocol of the url it's derived from
: unparse-protocol ( url -- )
    dup protocol>> [
        % "://" % unparse-host-part
    ] [
        dup host>> [
            "//" % unparse-host-part
        ] [
            drop
        ] if
    ] if* ;

M: url present
    [
        {
            [ unparse-protocol ]
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
        { [ "/" pick subseq-start not ] [ nip ] }
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

: url-addr ( url -- addr )
    [
        [ host>> ]
        [ port>> ]
        [ protocol>> protocol-port ]
        tri or <inet>
    ] [
        dup protocol>> secure-protocol?
        [ host>> <secure> ] [ drop ] if
    ] bi ;

: set-url-addr ( url addr -- url )
    [ host>> >>host ] [ port>> >>port ] bi ;

: ensure-port ( url -- url' )
    clone dup protocol>> '[ _ protocol-port or ] change-port ;

! Literal syntax
SYNTAX: URL" lexer get skip-blank parse-string >url suffix! ;

{ "urls" "prettyprint" } "urls.prettyprint" require-when
