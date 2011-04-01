! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init io.backend kernel namespaces threads ;
IN: io.thread

! The Cocoa and Gtk UI backend stops the I/O thread and takes
! over completely.
SYMBOL: io-thread-running?

: io-thread ( -- )
    sleep-time io-multiplex yield ;

: start-io-thread ( -- )
    t io-thread-running? set-global
    [ [ io-thread-running? get-global ] [ io-thread ] while ]
    "I/O wait" spawn drop ;

: stop-io-thread ( -- )
    f io-thread-running? set-global ;

[ start-io-thread ] "io.thread" add-startup-hook
