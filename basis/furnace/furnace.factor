! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make assocs sequences kernel classes splitting
vocabs.loader accessors strings combinators arrays
continuations present fry
urls html.elements
http http.server http.server.redirection http.server.remapping ;
IN: furnace

: nested-responders ( -- seq )
    responder-nesting get values ;

: each-responder ( quot -- )
   nested-responders swap each ; inline

: base-path ( string -- pair )
    dup responder-nesting get
    [ second class superclasses [ name>> = ] with contains? ] with find nip
    [ first ] [ "No such responder: " swap append throw ] ?if ;

: resolve-base-path ( string -- string' )
    "$" ?head [
        [
            "/" split1 [ base-path [  "/" % % ] each "/" % ] dip %
        ] "" make
    ] when ;

: vocab-path ( vocab -- path )
    dup vocab-dir vocab-append-path ;

: resolve-template-path ( pair -- path )
    [
        first2 [ vocabulary>> vocab-path % ] [ "/" % % ] bi*
    ] "" make ;

GENERIC: modify-query ( query responder -- query' )

M: object modify-query drop ;

GENERIC: modify-redirect-query ( query responder -- query' )

M: object modify-redirect-query drop ;

GENERIC: adjust-url ( url -- url' )

M: url adjust-url
    clone
        [ [ modify-query ] each-responder ] change-query
        [ resolve-base-path ] change-path
    relative-to-request ;

M: string adjust-url ;

GENERIC: adjust-redirect-url ( url -- url' )

M: url adjust-redirect-url
    adjust-url
    [ [ modify-redirect-query ] each-responder ] change-query ;

M: string adjust-redirect-url ;

GENERIC: link-attr ( tag responder -- )

M: object link-attr 2drop ;

GENERIC: modify-form ( responder -- )

M: object modify-form drop ;

: hidden-form-field ( value name -- )
    over [
        <input
            "hidden" =type
            =name
            present =value
        input/>
    ] [ 2drop ] if ;

: nested-forms-key "__n" ;

: request-params ( request -- assoc )
    dup method>> {
        { "GET" [ url>> query>> ] }
        { "HEAD" [ url>> query>> ] }
        { "POST" [
            post-data>>
            dup content-type>> "application/x-www-form-urlencoded" =
            [ content>> ] [ drop f ] if
        ] }
    } case ;

: referrer ( -- referrer/f )
    #! Typo is intentional, it's in the HTTP spec!
    "referer" request get header>> at
    dup [ >url ensure-port [ remap-port ] change-port ] when ;

: user-agent ( -- user-agent )
    "user-agent" request get header>> at "" or ;

: same-host? ( url -- ? )
    dup [
        url get [
            [ protocol>> ]
            [ host>> ]
            [ port>> remap-port ]
            tri 3array
        ] bi@ =
    ] when ;

: cookie-client-state ( key request -- value/f )
    swap get-cookie dup [ value>> ] when ;

: post-client-state ( key request -- value/f )
    request-params at ;

: client-state ( key -- value/f )
    request get dup method>> {
        { "GET" [ cookie-client-state ] }
        { "HEAD" [ cookie-client-state ] }
        { "POST" [ post-client-state ] }
    } case ;

SYMBOL: exit-continuation

: exit-with ( value -- )
    exit-continuation get continue-with ;

: with-exit-continuation ( quot -- value )
    '[ exit-continuation set @ ] callcc1 exit-continuation off ;

USE: vocabs.loader
"furnace.actions" require
"furnace.alloy" require
"furnace.asides" require
"furnace.auth" require
"furnace.auth.basic" require
"furnace.auth.features.deactivate-user" require
"furnace.auth.features.edit-profile" require
"furnace.auth.features.recover-password" require
"furnace.auth.features.registration" require
"furnace.auth.login" require
"furnace.auth.providers.assoc" require
"furnace.auth.providers.db" require
"furnace.auth.providers.null" require
"furnace.boilerplate" require
"furnace.chloe-tags" require
"furnace.conversations" require
"furnace.db" require
"furnace.json" require
"furnace.redirection" require
"furnace.referrer" require
"furnace.scopes" require
"furnace.sessions" require
"furnace.syndication" require
"webapps.user-admin" require
