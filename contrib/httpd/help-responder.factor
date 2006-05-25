! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help-responder
USING: cont-responder hashtables help html kernel namespaces
sequences ;

: help-responder ( filename -- )
    [
        "topic" "query" get hash
        dup empty? [ drop "handbook" ] when
        dup article-title
        [ [ help ] with-html-stream ] html-document
    ] show-final ;
