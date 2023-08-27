! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators furnace.utilities http http.server
http.server.filters http.server.redirection
http.server.remapping http.server.responses kernel namespaces
urls ;
IN: furnace.redirection

: <redirect> ( url -- response )
    adjust-redirect-url request get method>> {
        { "GET" [ <temporary-redirect> ] }
        { "HEAD" [ <temporary-redirect> ] }
        { "POST" [ <permanent-redirect> ] }
    } case ;

: >secure-url ( url -- url' )
    clone
        "https" >>protocol
        secure-http-port >>port ;

: <secure-redirect> ( url -- response )
    >secure-url <redirect> ;

TUPLE: redirect-responder to ;

: <redirect-responder> ( url -- responder )
    redirect-responder boa ;

M: redirect-responder call-responder* nip to>> <redirect> ;

TUPLE: secure-only < filter-responder ;

C: <secure-only> secure-only

: secure-connection? ( -- ? ) url get protocol>> "https" = ;

: if-secure ( quot -- response )
    {
        { [ secure-connection? ] [ call ] }
        { [ request get method>> "POST" = ] [ drop <400> ] }
        [ drop url get <secure-redirect> ]
    } cond ; inline

M: secure-only call-responder*
    '[ _ _ call-next-method ] if-secure ;
