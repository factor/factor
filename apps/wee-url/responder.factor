! Copyright (C) 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: generic hashtables help html httpd
io kernel math namespaces prettyprint sequences strings ;
IN: wee-url-responder

: fstore-name "wee-url.fstore" ;

SYMBOL: wee-shortcuts

SYMBOL: wee-fstore

wee-fstore fstore-name load-fstore

H{ } clone wee-shortcuts wee-fstore fstore-get

: save-shortcuts ( -- )
    wee-shortcuts wee-fstore fstore-set
    wee-fstore fstore-name save-fstore ;

: responder-url "responder-url" get ;

: wee-url ( string -- url )
    [
        "http://" %
        host %
        responder-url %
        %
    ] "" make ;

: letter-bank
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" ;

: random-letter letter-bank length random-int letter-bank nth ;

: random-url ( -- string )
    6 random-int 1+ [ drop random-letter ] map >string
    dup wee-shortcuts get hash-member? [ drop random-url ] when ;

: prepare-wee-url ( url -- url )
    CHAR: : over member? [ "http://" swap append ] unless ;

: set-symmetric-hash ( obj1 obj2 hash -- )
    3dup set-hash swapd set-hash ;

: add-shortcut ( url-long -- url-short )
    dup wee-shortcuts get hash* [
        nip
    ] [
        drop
        random-url [ wee-shortcuts get set-symmetric-hash ] keep
        save-shortcuts
    ] if ;

: url-prompt ( -- )
    serving-html
    "wee-url.com - wee URLs since 2007" [
        <form "get" =method responder-url =action form>
            "URL: " write
            <input "text" =type "url" =name input/>
            <input "submit" =type "Submit" =value input/>
        </form>
    ] simple-html-document ;

: url-submitted ( url-long url-short -- )
    "URL Submitted" [
        "URL: " write write terpri
        "wee-url: " write
        <a dup wee-url =href a> wee-url write </a> terpri
        "Back to " write
        <a responder-url =href a> "wee-url" write </a> terpri
    ] simple-html-document ;

: url-submit ( url -- )
    serving-html
    prepare-wee-url [ add-shortcut ] keep url-submitted ;

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
            drop url-prompt
        ] [
            wee-shortcuts get hash*
            [ permanent-redirect ] [ drop url-error ] if
        ] if
    ] if* ;

 [
    "wee-url" "responder" set
    [ wee-url-responder ] "get" set
] make-responder
