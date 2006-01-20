! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help-responder
USING: help html kernel sequences ;

: help-responder ( filename -- )
    dup empty? [ drop "handbook" ] when
    dup article-title
    [ [ (help) ] with-html-stream ] html-document ;
