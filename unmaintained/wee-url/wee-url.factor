! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs furnace html html.elements http.server
http.server.responders io kernel math math.ranges
namespaces random sequences store strings ;
IN: webapps.wee-url

SYMBOL: shortcuts
SYMBOL: store

! "wee-url.store" load-store store set-global
! H{ } clone shortcuts store get store-variable

: set-at-once ( value key assoc -- ? )
    2dup key? [ 3drop f ] [ set-at t ] if ;

: responder-url "responder/wee-url" ;

: wee-url ( string -- url )
    [
        "http://" %
        host %
        responder-url %
        %
    ] "" make ;

: letter-bank
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" ; inline

: random-url ( -- string )
    1 6 [a,b] random [ drop letter-bank random ] "" map-as
    dup shortcuts get key? [ drop random-url ] when ;

: add-shortcut ( url-long url-short -- url-short )
    shortcuts get set-at-once [
        store get save-store
    ] [
        drop
    ] if ;

: show-submit ( -- )
    serving-html
    "wee-url.com - wee URLs since 2007" [
        <form "get" =method "url-submit" =action form>
            "URL: " write
            <input "text" =type "url" =name input/>
            <input "submit" =type "Submit" =value input/>
        </form>
    ] simple-html-document ;

\ show-submit { } define-action

: url-submitted ( url-long url-short -- )
    "URL Submitted" [
        "URL: " write write nl
        "wee-url: " write
        <a dup wee-url =href a> wee-url write </a> nl
        "Back to " write
        <a responder-url =href a> "wee-url" write </a> nl
    ] simple-html-document ;

: url-submit ( url -- )
    [ add-shortcut ] keep
    url-submitted ;

\ url-submit {
    { "url" }
} define-action

: url-error ( -- )
    serving-html
    "wee-url error" [
        "No such link." write
    ] simple-html-document ;

: wee-url-responder ( url -- )
    "url" query-param [
        url-submit drop
    ] [
        dup empty? [
            drop show-submit
        ] [
            shortcuts get at*
            [ permanent-redirect ] [ drop url-error ] if
        ] if
    ] if* ;

! "wee-url" "wee-url-responder" "extra/webapps/wee-url" web-app
~
