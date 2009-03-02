! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads io.backend namespaces init math kernel ;
IN: io.thread

! The Cocoa UI backend stops the I/O thread and takes over
! completely.
SYMBOL: io-thread-running?

: io-thread ( -- )
    sleep-time io-multiplex yield ;

: start-io-thread ( -- )
    [ [ io-thread-running? get-global ] [ io-thread ] while ]
    "I/O wait" spawn drop ;

[
    t io-thread-running? set-global
    start-io-thread
] "io.thread" add-init-hook
