! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien generic assocs kernel kernel.private math
io.nonblocking sequences strings structs sbufs
threads unix vectors io.buffers io.backend
io.streams.duplex math.parser continuations system libc
qualified namespaces io.timeouts ;
QUALIFIED: io
IN: io.unix.backend

MIXIN: unix-io

! I/O tasks
TUPLE: io-task port callbacks ;

: io-task-fd io-task-port port-handle ;

: <io-task> ( port continuation/f class -- task )
    >r [ 1vector ] [ V{ } clone ] if* io-task construct-boa
    r> construct-delegate ; inline

TUPLE: input-task ;

: <input-task> ( port continuation class -- task )
    >r input-task <io-task> r> construct-delegate ; inline

TUPLE: output-task ;

: <output-task> ( port continuation class -- task )
    >r output-task <io-task> r> construct-delegate ; inline

GENERIC: do-io-task ( task -- ? )
GENERIC: io-task-container ( mx task -- hashtable )

! I/O multiplexers
TUPLE: mx fd reads writes ;

M: input-task io-task-container drop mx-reads ;

M: output-task io-task-container drop mx-writes ;

: <mx> ( -- mx ) f H{ } clone H{ } clone mx construct-boa ;

: construct-mx ( class -- obj ) <mx> swap construct-delegate ;

GENERIC: register-io-task ( task mx -- )
GENERIC: unregister-io-task ( task mx -- )
GENERIC: wait-for-events ( ms mx -- )

: fd/container ( task mx -- task fd container )
    over io-task-container >r dup io-task-fd r> ; inline

: check-io-task ( task mx -- )
    fd/container key? nip [
        "Cannot perform multiple reads from the same port" throw
    ] when ;

M: mx register-io-task ( task mx -- )
    2dup check-io-task fd/container set-at ;

: add-io-task ( task -- )
    mx get-global register-io-task ;

: with-port-continuation ( port quot -- port )
    [ "I/O" suspend drop ] curry with-timeout ; inline

M: mx unregister-io-task ( task mx -- )
    fd/container delete-at drop ;

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

: pop-callbacks ( mx task -- )
    dup rot unregister-io-task
    io-task-callbacks [ resume ] each ;

: handle-io-task ( mx task -- )
    dup do-io-task [ pop-callbacks ] [ 2drop ] if ;

: handle-timeout ( port mx assoc -- )
    >r swap port-handle r> delete-at* [
        "I/O operation cancelled" over io-task-port report-error
        pop-callbacks
    ] [
        2drop
    ] if ;

: cancel-io-tasks ( port mx -- )
    2dup
    dup mx-reads handle-timeout
    dup mx-writes handle-timeout ;

M: unix-io cancel-io ( port -- )
    mx get-global cancel-io-tasks ;

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
    read-task <input-task> ;

M: read-task do-io-task
    io-task-port dup refill
    [ [ reader-eof ] [ drop ] if ] keep ;

M: input-port (wait-to-read)
    [ <read-task> add-io-task ] with-port-continuation
    pending-error ;

! Writers
: write-step ( port -- ? )
    dup port-handle over buffer@ pick buffer-length write
    dup 0 >= [ swap buffer-consume f ] [ drop defer-error ] if ;

TUPLE: write-task ;

: <write-task> ( port continuation -- task )
    write-task <output-task> ;

M: write-task do-io-task
    io-task-port dup buffer-empty? over port-error or
    [ 0 swap buffer-reset t ] [ write-step ] if ;

: add-write-io-task ( port continuation -- )
    over port-handle mx get-global mx-writes at*
    [ io-task-callbacks push drop ]
    [ drop <write-task> add-io-task ] if ;

: (wait-to-write) ( port -- )
    [ add-write-io-task ] with-port-continuation drop ;

M: port port-flush ( port -- )
    dup buffer-empty? [ drop ] [ (wait-to-write) ] if ;

M: unix-io io-multiplex ( ms/f -- )
    mx get-global wait-for-events ;

M: unix-io init-stdio ( -- )
    0 1 handle>duplex-stream io:stdio set-global
    2 <writer> io:stderr set-global ;

! mx io-task for embedding an fd-based mx inside another mx
TUPLE: mx-port mx ;

: <mx-port> ( mx -- port )
    dup mx-fd f mx-port <port>
    { set-mx-port-mx set-delegate } mx-port construct ;

TUPLE: mx-task ;

: <mx-task> ( port -- task )
    f mx-task <io-task> ;

M: mx-task do-io-task
    io-task-port mx-port-mx 0 swap wait-for-events f ;

: multiplexer-error ( n -- )
    0 < [ err_no ignorable-error? [ (io-error) ] unless ] when ;
