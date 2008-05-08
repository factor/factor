! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists kernel math concurrency.promises
concurrency.mailboxes debugger accessors ;
IN: concurrency.count-downs

! http://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/CountDownLatch.html

TUPLE: count-down n promise ;

: count-down-check ( count-down -- )
    dup n>> zero? [ t swap promise>> fulfill ] [ drop ] if ;

: <count-down> ( n -- count-down )
    dup 0 < [ "Invalid count for count down" throw ] when
    <promise> \ count-down boa
    dup count-down-check ;

: count-down ( count-down -- )
    dup n>> dup zero?
    [ "Count down already done" throw ]
    [ 1- >>n count-down-check ] if ;

: await-timeout ( count-down timeout -- )
    >r promise>> r> ?promise-timeout ?linked t assert= ;

: await ( count-down -- )
    f await-timeout ;

: spawn-stage ( quot count-down -- )
    [ [ count-down ] curry compose ] keep
    "Count down stage"
    swap promise>> mailbox>> spawn-linked-to drop ;
