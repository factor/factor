! Copyright (c) 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors http.server http.server.dispatchers
http.server.static kernel namespaces sequences ;
IN: websites.factorcode

SYMBOL: users

: <factor-website> ( -- website )
    <dispatcher>
        "resource:extra/websites/factorcode/" <static> enable-fhtml >>default
        users get [
            [ "/home/" "/www/" surround <static> ] keep add-responder
        ] each ;

: init-testing ( -- )
    <factor-website> main-responder set-global ;
