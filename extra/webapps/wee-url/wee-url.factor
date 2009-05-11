! Copyright (C) 2007 Doug Coleman.
! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.ranges sequences random accessors 
kernel namespaces fry db.types db.tuples urls validators
html.components html.forms http http.server.dispatchers furnace
furnace.actions furnace.boilerplate furnace.redirection 
furnace.utilities continuations ;
IN: webapps.wee-url

TUPLE: wee-url < dispatcher ;

TUPLE: short-url short url ;

short-url "SHORT_URLS" {
    { "short" "SHORT" TEXT +user-assigned-id+ }
    { "url" "URL" TEXT +not-null+ }
} define-persistent

: letter-bank ( -- seq )
    CHAR: a CHAR: z [a,b]
    CHAR: A CHAR: Z [a,b]
    CHAR: 1 CHAR: 0 [a,b]
    3append ; foldable

: random-url ( -- string )
    1 6 [a,b] random [ letter-bank random ] "" replicate-as ;

: retry ( quot: ( -- ? )  n -- )
    swap [ drop ] prepose attempt-all ; inline

: insert-short-url ( short-url -- short-url )
    '[ _ dup random-url >>short insert-tuple ] 10 retry ;

: shorten ( url -- short )
    short-url new swap >>url dup select-tuple
    [ ] [ insert-short-url ] ?if short>> ;

: short>url ( short -- url )
    "$wee-url/go/" prepend >url adjust-url ;

: expand-url ( string -- url )
    short-url new swap >>short select-tuple url>> ;

: <shorten-action> ( -- action )
    <page-action>
        { wee-url "shorten" } >>template
        [ { { "url" [ v-url ] } } validate-params ] >>validate
        [
            "$wee-url/show/" "url" value shorten append >url <redirect>
        ] >>submit ;

: <show-action> ( -- action )
    <page-action>
        "short" >>rest
        [
            { { "short" [ v-one-word ] } } validate-params
            "short" value expand-url "url" set-value
            "short" value short>url "short" set-value
        ] >>init
        { wee-url "show" } >>template ;

: <go-action> ( -- action )
    <action>
        "short" >>rest
        [ { { "short" [ v-one-word ] } } validate-params ] >>init
        [ "short" value expand-url <redirect> ] >>display ;

: <wee-url> ( -- wee-url )
    wee-url new-dispatcher
        <shorten-action> "" add-responder
        <show-action> "show" add-responder
        <go-action> "go" add-responder
    <boilerplate>
        { wee-url "wee-url" } >>template ;
