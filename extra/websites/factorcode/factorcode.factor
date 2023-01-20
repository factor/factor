! Copyright (c) 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors http.server http.server.dispatchers
http.server.static kernel namespaces sequences ;
IN: websites.factorcode

: <factor-website> ( -- website )
    <dispatcher>
        "resource:extra/websites/factorcode/" <static> enable-fhtml >>default ;

: init-testing ( -- )
    <factor-website> main-responder set-global ;
