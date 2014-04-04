! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data combinators
destructors io.backend.unix libc kernel math.bitwise sequences
specialized-arrays unix unix.kqueue unix.time assocs
io.backend.unix.multiplexers classes.struct literals ;
SPECIALIZED-ARRAY: kevent
IN: io.backend.unix.multiplexers.kqueue

TUPLE: kqueue-mx < mx events ;

! We read up to 256 events at a time. This is an arbitrary
! constant...
CONSTANT: max-events 256

: <kqueue-mx> ( -- mx )
    kqueue-mx new-mx
        kqueue dup io-error >>fd
        max-events \ kevent <c-array> >>events ;

M: kqueue-mx dispose* fd>> close-file ;

: make-kevent ( fd filter flags -- event )
    \ kevent <struct>
        swap >>flags
        swap >>filter
        swap >>ident ;

: register-kevent ( kevent mx -- )
    fd>> swap 1 f 0 f kevent-func io-error ;

M: kqueue-mx add-input-callback ( thread fd mx -- )
    [ call-next-method ] [
        [ EVFILT_READ flags{ EV_ADD EV_ONESHOT } make-kevent ] dip
        register-kevent
    ] 2bi ;

M: kqueue-mx add-output-callback ( thread fd mx -- )
    [ call-next-method ] [
        [ EVFILT_WRITE flags{ EV_ADD EV_ONESHOT } make-kevent ] dip
        register-kevent
    ] 2bi ;

M: kqueue-mx remove-input-callbacks ( fd mx -- seq )
    2dup reads>> key? [
        [ call-next-method ] [
            [ EVFILT_READ EV_DELETE make-kevent ] dip
            register-kevent
        ] 2bi
    ] [ 2drop f ] if ;

M: kqueue-mx remove-output-callbacks ( fd mx -- seq )
    2dup writes>> key? [
        [
            [ EVFILT_WRITE EV_DELETE make-kevent ] dip
            register-kevent
        ] [ call-next-method ] 2bi
    ] [ 2drop f ] if ;

: wait-kevent ( mx timespec -- n )
    [
        [ fd>> f 0 ]
        [ events>> dup length ] bi
    ] dip kevent-func multiplexer-error ;

: handle-kevent ( mx kevent -- )
    [ ident>> swap ] [ filter>> ] bi {
        { EVFILT_READ [ input-available ] }
        { EVFILT_WRITE [ output-available ] }
    } case ;

: handle-kevents ( mx n -- )
    [ dup events>> ] dip head-slice
    [ handle-kevent ] with each ;

M: kqueue-mx wait-for-events ( nanos mx -- )
    swap dup [ make-timespec ] when
    dupd wait-kevent handle-kevents ;
