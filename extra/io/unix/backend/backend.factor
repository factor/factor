! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien generic assocs kernel kernel.private math
io.nonblocking sequences strings structs sbufs threads unix
vectors io.buffers io.backend io.streams.duplex math.parser
continuations system libc qualified namespaces ;
QUALIFIED: io
IN: io.unix.backend

! Multiplexer protocol
SYMBOL: unix-io-backend

HOOK: init-unix-io unix-io-backend ( -- )
HOOK: register-io-task unix-io-backend ( task -- )
HOOK: unregister-io-task unix-io-backend ( task -- )
HOOK: unix-io-multiplex unix-io-backend ( timeval -- )

TUPLE: unix-io ;

! Global variables
SYMBOL: read-tasks
SYMBOL: write-tasks

! Some general stuff
: file-mode OCT: 0666 ;

: (io-error) ( -- * ) err_no strerror throw ;

: check-null ( n -- ) zero? [ (io-error) ] when ;

: io-error ( n -- ) 0 < [ (io-error) ] when ;
 
M: integer init-handle ( fd -- )
    #! We drop the error code rather than calling io-error,
    #! since on OS X 10.3, this operation fails from init-io
    #! when running the Factor.app (presumably because fd 0 and
    #! 1 are closed).
    F_SETFL O_NONBLOCK fcntl drop ;

M: integer close-handle ( fd -- )
    close ;

: report-error ( error port -- )
    [ "Error on fd " % dup port-handle # ": " % swap % ] "" make
    swap set-port-error ;

: ignorable-error? ( n -- ? )
    dup EAGAIN number= swap EINTR number= or ;

: defer-error ( port -- ? )
    #! Return t if it is an unrecoverable error.
    err_no dup ignorable-error?
    [ 2drop f ] [ strerror swap report-error t ] if ;

! Associates a port with a list of continuations waiting on the
! port to finish I/O
TUPLE: io-task port callbacks ;

: <io-task> ( port continuation class -- task )
    >r 1vector io-task construct-boa r> construct-delegate ;
    inline

! Multiplexer
GENERIC: do-io-task ( task -- ? )
GENERIC: task-container ( task -- vector )

: io-task-fd io-task-port port-handle ;

: check-io-task ( task -- )
    dup io-task-fd swap task-container at [
        "Cannot perform multiple reads from the same port" throw
    ] when ;

: add-io-task ( task -- )
    dup check-io-task
    dup register-io-task
    dup io-task-fd over task-container set-at ;

: remove-io-task ( task -- )
    dup io-task-fd over task-container delete-at
    unregister-io-task ;

: pop-callbacks ( task -- )
    dup remove-io-task
    io-task-callbacks [ schedule-thread ] each ;

: handle-fd ( task -- )
    dup io-task-port touch-port
    dup do-io-task [ pop-callbacks ] [ drop ] if ;

: handle-timeout ( task -- )
    "Timeout" over io-task-port report-error pop-callbacks ;

! Readers
: reader-eof ( reader -- )
    dup buffer-empty? [ t over set-port-eof? ] when drop ;

: (refill) ( port -- n )
    dup port-handle over buffer-end rot buffer-capacity read ;

: refill ( port -- ? )
    #! Return f if there is a recoverable error
    dup buffer-empty? [
        dup (refill)  dup 0 >= [
            swap n>buffer t
        ] [
            drop defer-error
        ] if
    ] [
        drop t
    ] if ;

TUPLE: read-task ;

: <read-task> ( port continuation -- task )
    read-task <io-task> ;

M: read-task do-io-task
    io-task-port dup refill
    [ [ reader-eof ] [ drop ] if ] keep ;

M: read-task task-container
    drop read-tasks get-global ;

M: input-port (wait-to-read)
    [ <read-task> add-io-task stop ] callcc0 pending-error ;

! Writers
: write-step ( port -- ? )
    dup port-handle over buffer@ pick buffer-length write
    dup 0 >= [ swap buffer-consume f ] [ drop defer-error ] if ;

TUPLE: write-task ;

: <write-task> ( port continuation -- task )
    write-task <io-task> ;

M: write-task do-io-task
    io-task-port dup buffer-empty? over port-error or
    [ 0 swap buffer-reset t ] [ write-step ] if ;

M: write-task task-container
    drop write-tasks get-global ;

: add-write-io-task ( port continuation -- )
    over port-handle write-tasks get-global at
    [ io-task-callbacks push drop ]
    [ <write-task> add-io-task ] if* ;

: (wait-to-write) ( port -- )
    [ add-write-io-task stop ] callcc0 drop ;

M: port port-flush ( port -- )
    dup buffer-empty? [ drop ] [ (wait-to-write) ] if ;

M: unix-io io-multiplex ( ms -- )
    unix-io-multiplex ;

M: unix-io init-io ( -- )
    H{ } clone read-tasks set-global
    H{ } clone write-tasks set-global
    init-unix-io ;

M: unix-io init-stdio ( -- )
    0 1 handle>duplex-stream io:stdio set-global
    2 <writer> io:stderr set-global ;

: multiplexer-error ( n -- )
    0 < [ err_no ignorable-error? [ (io-error) ] unless ] when ;
