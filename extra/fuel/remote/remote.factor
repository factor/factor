! Copyright (C) 2009, 2010 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.
USING: io io.servers kernel math tty-server ;

IN: fuel.remote

<PRIVATE

: print-banner ( -- )
    "Starting server. Connect with 'M-x connect-to-factor' in Emacs"
    print flush ;

PRIVATE>

: fuel-start-remote-listener ( port/f -- )
    print-banner [ 9000 ] unless* <tty-server> start-server drop ;

: fuel-start-remote-listener* ( -- ) f fuel-start-remote-listener ;

! Remote connection
MAIN: fuel-start-remote-listener*
