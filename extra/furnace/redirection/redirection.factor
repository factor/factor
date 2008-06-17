! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators namespaces
io.servers.connection
http http.server http.server.redirection
furnace ;
IN: furnace.redirection

: <redirect> ( url -- response )
    adjust-url request get method>> {
        { "GET" [ <temporary-redirect> ] }
        { "HEAD" [ <temporary-redirect> ] }
        { "POST" [ <permanent-redirect> ] }
    } case ;

: >secure-url ( url -- url' )
    clone
        "https" >>protocol
        secure-port >>port ;

: <secure-redirect> ( url -- response )
    >secure-url <redirect> ;

TUPLE: redirect-responder to ;

: <redirect-responder> ( url -- responder )
    redirect-responder boa ;

M: redirect-responder call-responder* nip to>> <redirect> ;
