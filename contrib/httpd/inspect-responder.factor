! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inspect-responder
USING: cont-responder generic hashtables help html inspector
kernel lists namespaces sequences ;

! Mini object inspector
: http-inspect ( obj -- )
    "Inspecting " over summary append
    [ describe ] simple-html-document ;

M: general-t browser-link-href
    [ [ http-inspect ] show-final ] curry quot-url ;

: inspect-responder ( url -- )
    [ global http-inspect ] show-final ;
