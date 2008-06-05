! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators namespaces
logging urls http http.server http.server.responses ;
IN: http.server.redirection

: relative-to-request ( url -- url' )
    request get url>>
        clone
        f >>query
    swap derive-url ensure-port ;

: <custom-redirect> ( url code message -- response )
    <trivial-response>
        swap dup url? [ relative-to-request ] when
        "location" set-header ;

\ <custom-redirect> DEBUG add-input-logging

: <permanent-redirect> ( url -- response )
    301 "Moved Permanently" <custom-redirect> ;

: <temporary-redirect> ( url -- response )
    307 "Temporary Redirect" <custom-redirect> ;
