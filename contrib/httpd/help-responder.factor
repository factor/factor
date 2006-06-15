! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help-responder
USING: hashtables help html httpd io kernel namespaces sequences ;

: help-topic
    "topic" query-param dup empty? [ drop "handbook" ] when ;

: help-responder ( -- )
    serving-html
    help-topic dup article-title dup [
        <h1> write </h1> [ help ] with-html-stream
    ] html-document ;
