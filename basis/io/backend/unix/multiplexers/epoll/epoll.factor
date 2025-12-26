! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.struct kernel destructors bit-arrays
sequences assocs specialized-arrays math namespaces
libc locals fry unix unix.linux.epoll unix.time io.ports
io.backend.unix io.backend.unix.multiplexers ;
SPECIALIZED-ARRAY: epoll-event
IN: io.backend.unix.multiplexers.epoll

TUPLE: epoll-mx < mx events ;

! We read up to 256 events at a time. This is an arbitrary
! constant...
CONSTANT: max-events 256

: <epoll-mx> ( -- mx )
    epoll-mx new-mx
        max-events epoll_create dup io-error >>fd
        max-events <epoll-event-array> >>events ;

M: epoll-mx dispose* fd>> close-file ;

: make-event ( fd events -- event )
    epoll-event new
        swap >>events
        tuck data>> fd<< ;

:: do-epoll-ctl ( fd mx what events -- )
    mx fd>> what fd fd events make-event epoll_ctl io-error ;

: do-epoll-add ( fd mx events -- )
    EPOLL_CTL_ADD swap EPOLLONESHOT bitor do-epoll-ctl ;

: do-epoll-del ( fd mx events -- )
    EPOLL_CTL_DEL swap do-epoll-ctl ;

M: epoll-mx add-input-callback
    [ EPOLLIN do-epoll-add ] [ call-next-method ] 2bi ;

M: epoll-mx add-output-callback
    [ EPOLLOUT do-epoll-add ] [ call-next-method ] 2bi ;

M: epoll-mx remove-input-callbacks
    2dup reads>> key? [
        [ call-next-method ] [ EPOLLIN do-epoll-del ] 2bi
    ] [ 2drop f ] if ;

M: epoll-mx remove-output-callbacks
    2dup writes>> key? [
        [ EPOLLOUT do-epoll-del ] [ call-next-method ] 2bi
    ] [ 2drop f ] if ;

: wait-event ( mx nanos -- n )
    [ [ fd>> ] [ events>> ] bi dup length ] [ 1000000 /i ] bi*
    epoll_wait multiplexer-error ;

: handle-event ( event mx -- )
    [ data>> fd>> ] dip
    [ EPOLLIN EPOLLOUT bitor do-epoll-del ]
    [ input-available ] [ output-available ] 2tri ;

: handle-events ( mx n -- )
    [ dup events>> ] dip head-slice swap '[ _ handle-event ] each ;

M: epoll-mx wait-for-events
    swap 60000000 or dupd wait-event handle-events ;
