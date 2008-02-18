! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists kernel math concurrency.promises
concurrency.messaging ;
IN: concurrency.count-downs

! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/CountDownLatch.html

TUPLE: count-down n promise ;

: <count-down> ( n -- count-down )
    <dlist> count-down construct-boa ;

: count-down ( count-down -- )
    dup count-down-n dup zero? [
        "Count down already done" throw
    ] [
        1- dup pick set-count-down-n
        zero? [
            t swap count-down-promise fulfill
        ] [ drop ] if
    ] if ;

: await-timeout ( count-down timeout -- )
    >r count-down-promise r> ?promise-timeout drop ;

: spawn-stage ( quot name count-down -- )
    count-down-promise
    promise-mailbox spawn-linked-to drop ;

: await ( count-down -- )
    f await-timeout ;
