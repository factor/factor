! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: errors generic hashtables kernel lists math namespaces
sequences strings threads vectors ;

! These let us load the code into a CFactor instance using the
! old C-based I/O. They will be removed soon.
FORGET: can-read-line?
FORGET: can-read-count?
FORGET: can-write?
FORGET: add-write-io-task

TUPLE: io-task port callbacks ;
GENERIC: do-io-task ( task -- ? )
GENERIC: io-task-events ( task -- events )

! A hashtable in the global namespace mapping fd numbers to
! io-tasks. This is not a vector, since we need a quick way
! to find the number of elements, and a hashtable gives us
! this with the hash-size call.
SYMBOL: io-tasks

: file-mode OCT: 0600 ;

: io-error ( n -- ) 0 < [ errno strerror throw ] when ;

: open-read ( path -- fd )
    O_RDONLY file-mode sys-open dup io-error ;

: open-write ( path -- fd )
    O_WRONLY O_CREAT bitor O_TRUNC bitor file-mode sys-open
    dup io-error ;

TUPLE: port handle buffer error ;

C: port ( handle buffer -- port )
    [ >r <buffer> r> set-delegate ] keep
    [ set-port-handle ] keep ;

: buffered-port 8192 <port> ;

: >port< dup port-handle swap delegate ;

: pending-error ( reader -- ) port-error throw ;

TUPLE: reader line ready? ;

C: reader ( handle -- reader )
    [ >r buffered-port r> set-delegate ] keep ;

: read-line-loop ( line buffer -- ? )
    dup buffer-length 0 = [
        2drop f
    ] [
        dup buffer-pop dup CHAR: \n = [
            3drop t
        ] [
            pick sbuf-append read-line-loop
        ] ifte
    ] ifte ;

: read-line-step ( reader -- ? )
    [ dup reader-line swap read-line-loop dup ] keep
    set-reader-ready? ;

: init-reader ( count reader -- ) >r <sbuf> r> set-reader-line ;

: prepare-line ( reader -- ? )
    80 over init-reader read-line-step ;

: can-read-line? ( reader -- ? )
    dup pending-error
    dup reader-ready? [ drop t ] [ prepare-line ] ifte ;

: reader-eof ( reader -- )
    dup reader-line dup [
        length 0 = [ f over set-reader-line ] when
    ] [
        drop
    ] ifte  t swap set-reader-ready? ;

: read-step ( port -- ? )
    >port<
    tuck dup buffer-end swap buffer-capacity sys-read
    dup 0 >= [ swap n>buffer t ] [ 2drop f ] ifte ;

: refill ( reader -- )
    dup buffer-length 0 = [
        read-step drop
    ] [
        drop
    ] ifte ;

: eof? ( buffer -- ? ) buffer-fill 0 = ;

TUPLE: read-line-task ;

C: read-line-task ( port callbacks -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: read-line-task do-io-task
    io-task-port dup refill dup eof? [
        reader-eof t
    ] [
        read-line-step
    ] ifte ;

M: read-line-task io-task-events ( task -- events )
    drop read-events ;

: read-count-step ( count reader -- ? )
    dup reader-line -rot >r over length - r>
    2dup buffer-fill <= [
        buffer> swap sbuf-append t
    ] [
        buffer>> nip swap sbuf-append f
    ] ifte ;

: can-read-count? ( count reader -- ? )
    dup pending-error
    2dup reader-line length >= [
        2drop t
    ] [
        2dup init-reader read-count-step
    ] ifte ;

TUPLE: read-task count ;

C: read-task ( port callbacks -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: read-task do-io-task
    io-task-port dup refill dup eof? [
        nip reader-eof t
    ] [
        read-count-step
    ] ifte ;

M: read-task io-task-events ( task -- events )
    drop read-events ;

: pop-line ( reader -- str )
    dup reader-line dup [ sbuf>string ] when >r
    f over set-reader-line
    f swap set-reader-ready? r> ;

: read-fin ( reader -- str )
    dup pending-error  dup reader-ready? [
        pop-line
    ] [
        "reader not ready" throw
    ] ifte ;

TUPLE: writer ;

C: writer ( fd -- writer )
    [ >r buffered-port r> set-delegate ] keep ;

: write-step ( fd buffer -- ? )
    tuck dup buffer@ swap buffer-length sys-write
    dup 0 >= [ swap buffer-consume t ] [ 2drop f ] ifte ;

: can-write? ( len writer -- ? )
    #! If the buffer is empty and the string is too long,
    #! extend the buffer.
    dup pending-error
    dup eof? >r 2dup buffer-capacity > r> and [
        buffer-extend t
    ] [
        [ buffer-fill + ] keep buffer-capacity <=
    ] ifte ;

TUPLE: write-task ;

C: write-task ( port callbacks -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: write-task do-io-task
    io-task-port dup buffer-length 0 = over port-error or [
        0 swap buffer-reset t
    ] [
        >port< write-step
    ] ifte ;

M: write-task io-task-events ( task -- events )
    drop write-events ;

: write-fin ( str writer -- )
    dup pending-error
    >r dup string? [ ch>string ] unless r> >buffer ;

: can-copy? ( from -- ? )
    dup eof? [ read-step ] [ drop t ] ifte ;

: copy-from-task ( from to -- ? )
    over can-copy? [
        over eof? [
            2drop t
        ] [
            over buffer-fill over can-write? [
                dupd buffer-append 0 swap buffer-reset
            ] [
                2drop
            ] ifte f
        ] ifte
    ] [
        2drop f
    ] ifte ;

: io-task-fd io-task-port port-handle ;

: add-io-task ( task -- )
    dup io-task-fd io-tasks get 2dup hash [
        "Cannot perform multiple I/O ops on the same port" throw
    ] when set-hash ;

: add-write-io-task ( task -- )
    dup io-task-fd io-tasks get hash [
        dup write-task? [
            [
                >r io-task-callbacks r> io-task-callbacks append
            ] keep set-io-task-callbacks
        ] [
            add-io-task
        ] ifte
    ] [
        add-io-task
    ] ifte* ;

: remove-io-task ( task -- )
    io-task-fd io-tasks get remove-hash ;

: pop-callback ( task -- callback )
    dup io-task-callbacks uncons dup [
        rot set-io-task-callbacks
    ] [
        drop swap remove-io-task
    ] ifte ;

: handle-fd ( fd -- )
    io-tasks get hash dup do-io-task [
        pop-callback call
    ] [
        drop
    ] ifte ;

: do-io-tasks ( pollfds n -- )
    [
        dup pick pollfd-nth dup pollfd-revents 0 = [
            drop
        ] [
            pollfd-fd handle-fd
        ] ifte
    ] repeat drop ;

: init-pollfd ( task pollfd -- )
    over io-task-fd over set-pollfd-fd
    swap io-task-events swap set-pollfd-events ;

: make-pollfds ( -- pollfds n )
    io-tasks get dup hash-size [
        <pollfd-array> swap hash-values [
            dup io-task-fd pick pollfd-nth init-pollfd
        ] each
    ] keep ;

: io-multiplexer ( -- )
    make-pollfds dupd 0 sys-poll do-io-tasks ;

: io-loop ( -- ) io-multiplexer yield io-loop ;

: init-io ( -- )
    global [ <namespace> io-tasks set ] bind
    [ io-loop ] in-thread ;
