! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.thread
USING: concurrency.threads io.backend namespaces init ;

: io-thread ( -- )
    sleep-time io-multiplex yield io-thread ;

: start-io-thread ( -- )
    [ io-thread ]
    "I/O wait" spawn
    \ io-thread set-global ;

[ start-io-thread ] "io.thread" add-init-hook
