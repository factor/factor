! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: dlists kernel concurrency.threads continuations math ;
IN: concurrency.locks

! Simple critical sections
TUPLE: lock threads owner ;

: <lock> <dlist> lock construct-boa ;

: notify-1 ( dlist -- )
    dup dlist-empty? [ pop-back resume ] [ drop ] if ;

<PRIVATE

: wait-for-lock ( lock -- )
    [ swap lock-threads push-front ] suspend drop ;

: acquire-lock ( lock -- )
    dup lock-owner [ wait-for-lock ] when
    self swap set-lock-owner ;

: release-lock ( lock -- )
    f over set-lock-owner
    lock-threads notify-1 ;

: do-lock ( lock quot acquire release -- )
    >r >r over r> call over r> curry [ ] cleanup ; inline

PRIVATE>

: with-lock ( lock quot -- )
    [ acquire-lock ] [ release-lock ] do-lock ; inline

: with-reentrant-lock ( lock quot -- )
    over lock-owner self eq?
    [ nip call ] [ with-lock ] if ; inline

! Many-reader/single-writer locks
TUPLE: rw-lock readers writers reader# writer ;

: <rw-lock> ( -- lock )
    <dlist> <dlist> 0 f rw-lock construct-boa ;

<PRIVATE

: wait-for-read-lock ( lock -- )
    [ swap lock-readers push-front ] suspend drop ;

: acquire-read-lock ( lock -- )
    dup rw-lock-writer [ dup wait-for-read-lock ] when
    dup rw-lock-reader# 1+ swap set-rw-lock-reader# ;

: notify-writer ( lock -- )
    lock-writers notify-1 ;

: release-read-lock ( lock -- )
    dup rw-lock-reader# 1- dup pick set-rw-lock-reader#
    zero? [ notify-writers ] [ drop ] if ;

: wait-for-write-lock ( lock -- )
    [ swap lock-writers push-front ] suspend drop ;

: acquire-write-lock ( lock -- )
    dup rw-lock-writer over rw-lock-reader# 0 > or
    [ dup wait-for-write-lock ] when
    self over set-rw-lock-writer ;

: release-write-lock ( lock -- )
    f over set-rw-lock-writer
    dup rw-lock-readers dlist-empty?
    [ notify-writer ] [ rw-lock-readers notify-all ] if ;

: do-recursive-rw-lock ( lock quot quot' -- )
    >r over rw-lock-writer self eq? [ nip call ] r> if ; inline

PRIVATE>

: with-read-lock ( lock quot -- )
    [
        [ acquire-read-lock ] [ release-read-lock ] do-lock
    ] do-recursive-rw-lock ; inline

: with-write-lock ( lock quot -- )
    [
        [ acquire-write-lock ] [ release-write-lock ] do-lock
    ] do-recursive-rw-lock ; inline
