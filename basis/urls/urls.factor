! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors ascii assocs combinators
combinators.short-circuit io.pathnames io.sockets
io.sockets.secure kernel lexer linked-assocs make math.parser
multiline namespaces peg.ebnf present protocols sequences
sequences.generalizations splitting strings strings.parser
urls.encoding vocabs.loader ;

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

ERROR: malformed-port string ;

: parse-port ( string -- port/f )
    [ f ] [ [ string>number ] [ malformed-port ] ?unless ] if-empty ;

: parse-host ( string -- host/f port/f )
    [
        ":" split1-last [ url-decode ] [ parse-port ] bi*
    ] [ f f ] if* ;

GENERIC: >url ( obj -- url )

M: f >url drop <url> ;

M: url >url ;

<PRIVATE

: remove-dot-segments ( path -- path' )
    [ "//" split1 ] [ "/" glue ] while*
    [ "/./" split1 ] [ "/" glue ] while*
    [ "/../" split1 ] [ [ "/" split1-last drop ] dip "/" glue ] while*
    "/.." ?tail [ "/" split1-last drop "/" append ] when
    "../" ?head [ "/" prepend ] when
    "./" ?head [ "/" prepend ] when
    "/." ?tail [ "/" append ] when
    [ "/" ] when-empty ;

: parse-path ( string -- path )
    "/" split [ url-decode "/" "%2F" replace ] map "/" join
    remove-dot-segments ;

EBNF: parse-url [=[

protocol = [a-zA-Z0-9.+-]+ => [[ url-decode ]]
username = [^/:@#?]*       => [[ url-decode ]]
password = [^/:@#?]*       => [[ url-decode ]]
path     = [^#?]+          => [[ parse-path ]]
query    = [^#]+           => [[ query>assoc ]]
anchor   = .+              => [[ url-decode ]]
hostname = [^/#?:]+        => [[ url-decode ]]
ipv6     = "[" [^\]]+ "]"  => [[ concat url-decode ]]
port     = [^/#?]+         => [[ url-decode parse-port ]]

auth     = username (":"~ password?)? "@"~
host     = (ipv6 | hostname) (":"~ port?)?

url      = (protocol ":"~)?
           ("//"~ auth? host?)?
           path?
           ("?"~ query?)?
           ("#"~ anchor?)?

]=]

PRIVATE>

M: string >url
    [ <url> ] dip parse-url 5 firstn {
        [ >lower >>protocol ]
        [
            [
                [ first [ first2 [ >>username ] [ >>password ] bi* ] when* ]
                [ second [ first2 [ >>host ] [ >>port ] bi* ] when* ] bi
            ] when*
        ]
        [ >>path ]
        [ >>query ]
        [ >>anchor ]
    } spread dup host>> [ [ "/" or ] change-path ] when ;

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
        url-encode % password>> [ ":" % url-encode % ] when* "@" %
    ] [ 2drop ] if ;

: url-port ( url -- port/f )
    [ port>> ] [ protocol>> lookup-protocol-port ] bi over =
    [ drop f ] when ;

: ipv6-host ( host -- host/ipv6 ipv6? )
    dup { [ "[" head? ] [ "]" tail? ] } 1&& [
        1 swap index-of-last subseq t
    ] [ f ] if ;

: unparse-host ( url -- host )
    host>> ipv6-host [ url-encode ] [ [ "[" "]" surround ] when ] bi* ;

: unparse-host-part ( url -- )
    {
        [ unparse-username-password ]
        [ unparse-host % ]
        [ url-port [ ":" % # ] when* ]
        [ path>> "/" head? [ "/" % ] unless ]
    } cleave ;

! URL" //foo.com" takes on the protocol of the url it's derived from
: unparse-protocol ( url -- )
    protocol>> [ % ":" % ] when* ;

: unparse-authority ( url -- )
    dup host>> [ "//" % unparse-host-part ] [ drop ] if ;

: unparse-path ( url -- )
    path>> "/" split [
        "%2F" "/" replace url-encode "/" "%2F" replace
    ] map "/" join % ;

M: url present
    [
        {
            [ unparse-protocol ]
            [ unparse-authority ]
            [ unparse-path ]
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
        { [ over "/" subseq-index not ] [ nip ] }
        [ [ "/" split1-last drop "/" ] dip 3append ]
    } cond remove-dot-segments ;

<PRIVATE

: derive-port ( url base -- url' )
    over relative-url? [ [ port>> ] either? ] [ drop port>> ] if ;

: derive-path ( url base -- url' )
    [ path>> ] bi@ swap url-append-path ;

PRIVATE>

: derive-url ( base url -- url' )
    [ >url clone ] dip >url over {
        [ [ protocol>>  ] either? >>protocol ]
        [ [ username>>  ] either? >>username ]
        [ [ password>>  ] either? >>password ]
        [ [ host>>      ] either? >>host ]
        [ derive-port             >>port ]
        [ derive-path             >>path ]
        [ [ query>>     ] either? >>query ]
        [ [ anchor>>    ] either? >>anchor ]
    } 2cleave ;

: redacted-url ( url -- url' )
    clone [ "xxxxx" and ] change-password ;

! Half-baked stuff follows
: secure-protocol? ( protocol -- ? )
    "https" = ;

: url-addr ( url -- addr )
    [
        [ host>> ipv6-host drop ]
        [ port>> ]
        [ protocol>> lookup-protocol-port ]
        tri or <inet>
    ] [
        dup protocol>> secure-protocol?
        [ host>> ipv6-host drop <secure> ] [ drop ] if
    ] bi ;

: set-url-addr ( url addr -- url )
    [ [ host>> ] [ inet6? ] bi [ "[" "]" surround ] when >>host ]
    [ port>> >>port ] bi ;

: ensure-port ( url -- url' )
    clone dup protocol>> '[ _ lookup-protocol-port or ] change-port ;

! Literal syntax
SYNTAX: URL" lexer get skip-blank parse-string >url suffix! ;

{ "urls" "prettyprint" } "urls.prettyprint" require-when
