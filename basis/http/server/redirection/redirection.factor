! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors http http.server.responses kernel logging
namespaces strings urls ;
IN: http.server.redirection

GENERIC: relative-to-request ( url -- url' )

M: string relative-to-request ;

M: url relative-to-request
    url get
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
