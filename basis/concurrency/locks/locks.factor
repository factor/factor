! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit
concurrency.conditions continuations deques dlists kernel math
threads ;
IN: concurrency.locks

! Simple critical sections
TUPLE: lock threads owner reentrant? ;

: <lock> ( -- lock )
    <dlist> f f lock boa ;

: <reentrant-lock> ( -- lock )
    <dlist> f t lock boa ;

<PRIVATE

: acquire-lock ( lock timeout -- )
    over owner>>
    [ 2dup [ threads>> ] dip "lock" wait ] when drop
    self >>owner drop ;

: release-lock ( lock -- )
    f >>owner
    threads>> notify-1 ;

:: do-lock ( lock timeout quot acquire release -- )
    lock timeout acquire call
    quot lock release curry finally ; inline

: (with-lock) ( lock timeout quot -- )
    [ acquire-lock ] [ release-lock ] do-lock ; inline

PRIVATE>

: with-lock-timeout ( lock timeout quot -- )
    pick reentrant?>> [
        pick owner>> self eq? [
            2nip call
        ] [
            (with-lock)
        ] if
    ] [
        (with-lock)
    ] if ; inline

: with-lock ( lock quot -- )
    f swap with-lock-timeout ; inline

! Many-reader/single-writer locks
TUPLE: rw-lock readers writers reader# writer ;

: <rw-lock> ( -- lock )
    <dlist> <dlist> 0 f rw-lock boa ;

<PRIVATE

: add-reader ( lock -- )
    [ 1 + ] change-reader# drop ;

: acquire-read-lock ( lock timeout -- )
    over writer>>
    [ 2dup [ readers>> ] dip "read lock" wait ] when drop
    add-reader ;

: notify-writer ( lock -- )
    writers>> notify-1 ;

: remove-reader ( lock -- )
    [ 1 - ] change-reader# drop ;

: release-read-lock ( lock -- )
    dup remove-reader
    dup reader#>> zero? [ notify-writer ] [ drop ] if ;

: acquire-write-lock ( lock timeout -- )
    over writer>> pick reader#>> 0 > or
    [ 2dup [ writers>> ] dip "write lock" wait ] when drop
    self >>writer drop ;

: release-write-lock ( lock -- )
    f >>writer
    dup readers>> deque-empty?
    [ notify-writer ] [ readers>> notify-all ] if ;

: reentrant-read-lock-ok? ( lock -- ? )
    ! If we already have a write lock, then we can grab a read
    ! lock too.
    writer>> self eq? ;

: reentrant-write-lock-ok? ( lock -- ? )
    ! The only case where we have a writer and > 1 reader is
    ! write -> read re-entrancy, and in this case we prohibit
    ! a further write -> read -> write re-entrancy.
    { [ writer>> self eq? ] [ reader#>> zero? ] } 1&& ;

PRIVATE>

: with-read-lock-timeout ( lock timeout quot -- )
    pick reentrant-read-lock-ok? [
        [ drop add-reader ] [ remove-reader ] do-lock
    ] [
        [ acquire-read-lock ] [ release-read-lock ] do-lock
    ] if ; inline

: with-read-lock ( lock quot -- )
    f swap with-read-lock-timeout ; inline

: with-write-lock-timeout ( lock timeout quot -- )
    pick reentrant-write-lock-ok? [ 2nip call ] [
        [ acquire-write-lock ] [ release-write-lock ] do-lock
    ] if ; inline

: with-write-lock ( lock quot -- )
    f swap with-write-lock-timeout ; inline
