! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: file-responder
USING: html httpd io kernel math namespaces
parser sequences strings ;

: serving-path ( filename -- filename )
    [ "" ] unless* "doc-root" get swap append ;

: file-response ( mime-type length -- )
    [
        number>string "Content-Length" set
        "Content-Type" set
    ] make-hash "200 OK" response terpri ;

: serve-static ( filename mime-type -- )
    over file-length file-response  "method" get "head" = [
        drop
    ] [
        <file-reader> stdio get stream-copy
    ] if ;

: serve-file ( filename -- )
    dup mime-type dup "application/x-factor-server-page" = [
        drop run-file
    ] [
        serve-static
    ] if ;

: list-directory ( directory -- )
    serving-html
     "method" get "head" = [
        drop
    ] [
        "request" get [ dup log-message directory. ] simple-html-document
    ] if ;

: serve-directory ( filename -- )
    dup "/" tail? [
        dup "index.html" append dup exists? [
            nip serve-file
        ] [
            drop list-directory
        ] if
    ] [
        drop directory-no/
    ] if ;

: serve-object ( filename -- )
    dup directory? [ serve-directory ] [ serve-file ] if ;

: file-responder ( -- )
    "doc-root" get [
        "argument" get serving-path dup exists? [
            serve-object
        ] [
            drop "404 not found" httpd-error
        ] if
    ] [
        "404 doc-root not set" httpd-error
    ] if ;
