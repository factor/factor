! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.encodings.utf8 io.servers.connection kernel
listener math ;

IN: fuel.remote

<PRIVATE

: server ( port -- server )
    <threaded-server>
        "tty-server" >>name
        utf8 >>encoding
        swap local-server >>insecure
        [ listener ] >>handler
        f >>timeout ;

: print-banner ( -- )
    "Starting server. Connect with 'M-x connect-to-factor' in Emacs"
    write nl flush ;

PRIVATE>

: fuel-start-remote-listener ( port/f -- )
    print-banner integer? [ 9000 ] unless* server start-server ;

: fuel-start-remote-listener* ( -- ) f fuel-start-remote-listener ;

