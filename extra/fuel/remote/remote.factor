! Copyright (C) 2009, 2010 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors io io.encodings.utf8 io.servers kernel math
namespaces tty-server ;

IN: fuel.remote

<PRIVATE

: print-banner ( -- )
    "Starting server. Connect with 'M-x connect-to-factor' in Emacs"
    write nl flush ;

PRIVATE>

: fuel-start-remote-listener ( port/f -- )
    print-banner integer? [ 9000 ] unless* <tty-server> start-server drop ;

: fuel-start-remote-listener* ( -- ) f fuel-start-remote-listener ;
