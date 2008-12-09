! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types combinators io.unix.backend
kernel math.bitwise sequences struct-arrays unix unix.kqueue
unix.time ;
IN: io.unix.kqueue

TUPLE: kqueue-mx < mx events monitors ;

: max-events ( -- n )
    #! We read up to 256 events at a time. This is an arbitrary
    #! constant...
    256 ; inline

: <kqueue-mx> ( -- mx )
    kqueue-mx new-mx
        H{ } clone >>monitors
        kqueue dup io-error >>fd
        max-events "kevent" <struct-array> >>events ;

: make-kevent ( fd filter flags -- event )
    "kevent" <c-object>
    [ set-kevent-flags ] keep
    [ set-kevent-filter ] keep
    [ set-kevent-ident ] keep ;

: register-kevent ( kevent mx -- )
    fd>> swap 1 f 0 f kevent io-error ;

M: kqueue-mx add-input-callback ( thread fd mx -- )
    [ call-next-method ] [
        [ EVFILT_READ { EV_ADD EV_ONESHOT } flags make-kevent ] dip
        register-kevent
    ] 2bi ;

M: kqueue-mx add-output-callback ( thread fd mx -- )
    [ call-next-method ] [
        [ EVFILT_WRITE EV_DELETE make-kevent ] dip
        register-kevent
    ] 2bi ;

: cancel-input-callbacks ( fd mx -- seq )
    [
        [ EVFILT_READ EV_DELETE make-kevent ] dip
        register-kevent
    ] [ remove-input-callbacks ] 2bi ;

: cancel-output-callbacks ( fd mx -- seq )
    [
        [ EVFILT_WRITE EV_DELETE make-kevent ] dip
        register-kevent
    ] [ remove-output-callbacks ] 2bi ;

M: fd cancel-operation ( fd -- )
    dup disposed>> [ drop ] [
        fd>>
        mx get-global
        [ cancel-input-callbacks [ t swap resume-with ] each ]
        [ cancel-output-callbacks [ t swap resume-with ] each ]
        2bi
    ] if ;

: wait-kevent ( mx timespec -- n )
    [
        [ fd>> f 0 ]
        [ events>> [ underlying>> ] [ length ] bi ] bi
    ] dip kevent
    dup multiplexer-error ;

: handle-kevent ( mx kevent -- )
    [ kevent-ident swap ] [ kevent-filter ] bi {
        { EVFILT_READ [ input-available ] }
        { EVFILT_WRITE [ output-available ] }
    } case ;

: handle-kevents ( mx n -- )
    [ dup events>> ] dip head-slice [ handle-kevent ] with each ;

M: kqueue-mx wait-for-events ( us mx -- )
    swap dup [ make-timespec ] when
    dupd wait-kevent handle-kevents ;
