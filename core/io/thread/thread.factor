! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.thread
USING: threads io.backend namespaces init ;

: io-thread ( -- )
    sleep-time io-multiplex yield ;

: start-io-thread ( -- )
    [ io-thread t ]
    "I/O wait" spawn-server
    \ io-thread set-global ;

[ start-io-thread ] "io.thread" add-init-hook
