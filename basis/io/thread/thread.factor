! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: continuations init io.backend kernel namespaces threads ;
IN: io.thread

! The Cocoa and Gtk UI backend stops the I/O thread and takes
! over completely.
SYMBOL: io-thread-running?

TUPLE: io-thread < thread ;

: <io-thread> ( -- thread )
    [
        [ io-thread-running? get-global ]
        [ sleep-time io-multiplex yield ]
        while
    ]
    "I/O wait"
    io-thread new-thread ;

M: io-thread error-in-thread die drop rethrow ;

: start-io-thread ( -- )
    t io-thread-running? set-global
    <io-thread> (spawn) ;

: stop-io-thread ( -- )
    f io-thread-running? set-global ;

STARTUP-HOOK: start-io-thread
