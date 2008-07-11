! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators namespaces fry
io.servers.connection urls
http http.server http.server.redirection http.server.filters
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

TUPLE: secure-only < filter-responder ;

C: <secure-only> secure-only

: if-secure ( quot -- )
    >r url get protocol>> "http" =
    [ url get <secure-redirect> ]
    r> if ; inline

M: secure-only call-responder*
    '[ , , call-next-method ] if-secure ;
