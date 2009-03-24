! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors http.client kernel unicode.categories
sequences urls splitting combinators splitting.monotonic
combinators.short-circuit assocs unicode.case arrays
math.parser calendar.format make ;
IN: robots

! visit-time is GMT, request-rate is pages/second 
! crawl-rate is seconds
TUPLE: rules user-agents allows disallows
visit-time request-rate crawl-delay unknowns ;

<PRIVATE

: >robots.txt-url ( url -- url' )
    >url URL" robots.txt" derive-url ;

: get-robots.txt ( url -- headers robots.txt )
    >robots.txt-url http-get ;

: normalize-robots.txt ( string -- sitemaps seq )
    string-lines
    [ [ blank? ] trim ] map
    [ "#" head? not ] filter harvest
    [ ":" split1 [ [ blank? ] trim ] bi@ [ >lower ] dip  ] { } map>assoc
    [ first "sitemap" = ] partition [ values ] dip
    [
        {
            [ [ first "user-agent" = ] bi@ and ]
            [ nip first "user-agent" = not ]
        } 2|| 
    ] monotonic-split ;

: <rules> ( -- rules )
    rules new
        V{ } clone >>user-agents
        V{ } clone >>allows
        V{ } clone >>disallows
        H{ } clone >>unknowns ;

: add-user-agent ( rules agent -- rules ) over user-agents>> push ;
: add-allow ( rules allow -- rules ) over allows>> push ;
: add-disallow ( rules disallow -- rules ) over disallows>> push ;

: parse-robots.txt-line ( rules seq -- rules )
    first2 swap {
        { "user-agent" [ add-user-agent ] }
        { "allow" [ add-allow ] }
        { "disallow" [ add-disallow ] }
        { "crawl-delay" [ string>number >>crawl-delay ] }
        { "request-rate" [ string>number >>request-rate ] }
        {
            "visit-time" [ "-" split1 [ hhmm>timestamp ] bi@ 2array
            >>visit-time
        ] }
        [ pick unknowns>> push-at ]
    } case ;

PRIVATE>

: parse-robots.txt ( string -- sitemaps rules-seq )
    normalize-robots.txt [
        [ <rules> dup ] dip [ parse-robots.txt-line drop ] with each
    ] map ;

: robots ( url -- sitemaps rules-seq )
    get-robots.txt nip parse-robots.txt ;
