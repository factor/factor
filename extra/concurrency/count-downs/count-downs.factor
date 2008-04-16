! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists kernel math concurrency.promises
concurrency.mailboxes ;
IN: concurrency.count-downs

! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/CountDownLatch.html

TUPLE: count-down n promise ;

: count-down-check ( count-down -- )
    dup count-down-n zero? [
        t swap count-down-promise fulfill
    ] [ drop ] if ;

: <count-down> ( n -- count-down )
    dup 0 < [ "Invalid count for count down" throw ] when
    <promise> \ count-down boa
    dup count-down-check ;

: count-down ( count-down -- )
    dup count-down-n dup zero? [
        "Count down already done" throw
    ] [
        1- over set-count-down-n
        count-down-check
    ] if ;

: await-timeout ( count-down timeout -- )
    >r count-down-promise r> ?promise-timeout drop ;

: await ( count-down -- )
    f await-timeout ;

: spawn-stage ( quot count-down -- )
    [ [ count-down ] curry compose ] keep
    "Count down stage"
    swap count-down-promise
    promise-mailbox spawn-linked-to drop ;
