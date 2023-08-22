! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.mailboxes concurrency.promises
kernel math ;
IN: concurrency.count-downs

! https://java.sun.com/j2se/1.5.0/docs/api/java/util/concurrent/CountDownLatch.html

TUPLE: count-down-tuple n promise ;

: count-down-check ( count-down -- )
    dup n>> zero? [ t swap promise>> fulfill ] [ drop ] if ;

ERROR: invalid-count-down-count count ;

: <count-down> ( n -- count-down )
    dup 0 < [ invalid-count-down-count ] when
    <promise> \ count-down-tuple boa
    dup count-down-check ;

ERROR: count-down-already-done ;

: count-down ( count-down -- )
    dup n>> dup zero?
    [ count-down-already-done ]
    [ 1 - >>n count-down-check ] if ;

: await-timeout ( count-down timeout -- )
    [ promise>> ] dip ?promise-timeout ?linked t assert= ;

: await ( count-down -- )
    f await-timeout ;

: spawn-stage ( quot count-down -- )
    [ '[ @ _ count-down ] ] keep
    "Count down stage"
    swap promise>> mailbox>> spawn-linked-to drop ;
