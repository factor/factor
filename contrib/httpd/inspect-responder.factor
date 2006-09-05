! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inspect-responder
USING: callback-responder generic hashtables help html httpd
tools kernel namespaces prettyprint sequences ;

! Mini object inspector
: http-inspect ( obj -- )
    dup summary [ describe ] simple-html-document ;

M: general-t browser-link-href
    [ http-inspect ] curry t register-html-callback ;

: inspect-responder ( url -- )
    serving-html global http-inspect ;
