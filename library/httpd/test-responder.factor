! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: test-responder
USING: html httpd kernel test ;

: test-responder ( argument -- )
    drop
    serving-html
    "Factor Test Suite" [ all-tests ] simple-html-document ;
