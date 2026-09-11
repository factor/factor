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
    [
        epoll-mx new-mx |dispose
            max-events <epoll-event-array> >>events
            max-events epoll_create dup io-error >>fd
    ] with-destructors ;

M: epoll-mx dispose* fd>> [ close-file ] when* ;

: make-event ( fd events -- event )
    epoll-event new
        swap >>events
        tuck data>> fd<< ;

:: do-epoll-ctl ( fd mx what events -- )
    mx fd>> what fd fd events make-event epoll_ctl io-error ;

:: do-epoll-add ( fd mx events -- )
    fd mx reads>> key? EPOLLIN 0 ?
    fd mx writes>> key? EPOLLOUT 0 ? bitor :> existing
    fd mx existing zero? EPOLL_CTL_ADD EPOLL_CTL_MOD ?
    existing events bitor EPOLLONESHOT bitor do-epoll-ctl ;

: do-epoll-del ( fd mx events -- )
    EPOLL_CTL_DEL swap do-epoll-ctl ;

M: epoll-mx add-input-callback
    [ EPOLLIN do-epoll-add ] [ call-next-method ] 2bi ;

M: epoll-mx add-output-callback
    [ EPOLLOUT do-epoll-add ] [ call-next-method ] 2bi ;

M: epoll-mx remove-input-callbacks
    2dup reads>> key? [
        [
            2dup writes>> key?
            [ EPOLL_CTL_MOD EPOLLOUT EPOLLONESHOT bitor do-epoll-ctl ]
            [ EPOLLIN do-epoll-del ] if
        ] [ call-next-method ] 2bi
    ] [ 2drop f ] if ;

M: epoll-mx remove-output-callbacks
    2dup writes>> key? [
        [
            2dup reads>> key?
            [ EPOLL_CTL_MOD EPOLLIN EPOLLONESHOT bitor do-epoll-ctl ]
            [ EPOLLOUT do-epoll-del ] if
        ] [ call-next-method ] 2bi
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
