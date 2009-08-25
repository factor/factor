! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types kernel destructors bit-arrays
sequences assocs struct-arrays math namespaces locals fry unix
unix.linux.epoll unix.time io.ports io.backend.unix
io.backend.unix.multiplexers ;
IN: io.backend.unix.multiplexers.epoll

TUPLE: epoll-mx < mx events ;

: max-events ( -- n )
    #! We read up to 256 events at a time. This is an arbitrary
    #! constant...
    256 ; inline

: <epoll-mx> ( -- mx )
    epoll-mx new-mx
        max-events epoll_create dup io-error >>fd
        max-events "epoll-event" <struct-array> >>events ;

M: epoll-mx dispose* fd>> close-file ;

: make-event ( fd events -- event )
    "epoll-event" <c-object>
    [ set-epoll-event-events ] keep
    [ set-epoll-event-fd ] keep ;

:: do-epoll-ctl ( fd mx what events -- )
    mx fd>> what fd fd events make-event epoll_ctl io-error ;

: do-epoll-add ( fd mx events -- )
    EPOLL_CTL_ADD swap EPOLLONESHOT bitor do-epoll-ctl ;

: do-epoll-del ( fd mx events -- )
    EPOLL_CTL_DEL swap do-epoll-ctl ;

M: epoll-mx add-input-callback ( thread fd mx -- )
    [ EPOLLIN do-epoll-add ] [ call-next-method ] 2bi ;

M: epoll-mx add-output-callback ( thread fd mx -- )
    [ EPOLLOUT do-epoll-add ] [ call-next-method ] 2bi ;

M: epoll-mx remove-input-callbacks ( fd mx -- seq )
    2dup reads>> key? [
        [ call-next-method ] [ EPOLLIN do-epoll-del ] 2bi
    ] [ 2drop f ] if ;

M: epoll-mx remove-output-callbacks ( fd mx -- seq )
    2dup writes>> key? [
        [ EPOLLOUT do-epoll-del ] [ call-next-method ] 2bi
    ] [ 2drop f ] if ;

: wait-event ( mx us -- n )
    [ [ fd>> ] [ events>> ] bi dup length ] [ 1000 /i ] bi*
    epoll_wait multiplexer-error ;

: handle-event ( event mx -- )
    [ epoll-event-fd ] dip
    [ EPOLLIN EPOLLOUT bitor do-epoll-del ]
    [ input-available ] [ output-available ] 2tri ;

: handle-events ( mx n -- )
    [ dup events>> ] dip head-slice swap '[ _ handle-event ] each ;

M: epoll-mx wait-for-events ( us mx -- )
    swap 60000000 or dupd wait-event handle-events ;
