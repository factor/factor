! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors debugger io io.encodings.utf8 io.servers.connection
kernel listener math namespaces ;

IN: fuel.remote

<PRIVATE

: start-listener ( -- )
    [ [ print-error-and-restarts ] error-hook set listener ] with-scope ;

: server ( port -- server )
    utf8 <threaded-server>
        "tty-server" >>name
        swap local-server >>insecure
        [ start-listener ] >>handler
        f >>timeout ;

: print-banner ( -- )
    "Starting server. Connect with 'M-x connect-to-factor' in Emacs"
    write nl flush ;

PRIVATE>

: fuel-start-remote-listener ( port/f -- )
    print-banner integer? [ 9000 ] unless* server start-server ;

: fuel-start-remote-listener* ( -- ) f fuel-start-remote-listener ;

