! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien generic assocs kernel kernel.private math
io.nonblocking sequences strings structs sbufs threads unix
vectors io.buffers io.backend io.streams.duplex math.parser
continuations system libc qualified namespaces ;
QUALIFIED: io
IN: io.unix.backend

MIXIN: unix-io

! I/O tasks
TUPLE: io-task port callbacks ;

: io-task-fd io-task-port port-handle ;

: <io-task> ( port continuation class -- task )
    >r 1vector io-task construct-boa r> construct-delegate ;
    inline

GENERIC: do-io-task ( task -- ? )
GENERIC: io-task-container ( mx task -- hashtable )

! I/O multiplexers
TUPLE: mx fd reads writes ;

: <mx> ( -- mx ) f H{ } clone H{ } clone mx construct-boa ;

: construct-mx ( class -- obj ) <mx> swap construct-delegate ;

GENERIC: register-io-task ( task mx -- )
GENERIC: unregister-io-task ( task mx -- )
GENERIC: unix-io-multiplex ( ms mx -- )

: fd/container ( task mx -- task fd container )
    over io-task-container >r dup io-task-fd r> ; inline

: check-io-task ( task mx -- )
    fd/container key? nip [
        "Cannot perform multiple reads from the same port" throw
    ] when ;

M: mx register-io-task ( task mx -- )
    2dup check-io-task fd/container set-at ;

: add-io-task ( task -- ) mx get-global register-io-task ;

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
    io-task-callbacks [ schedule-thread ] each ;

: handle-io-task ( mx task -- )
    dup io-task-port touch-port
    dup do-io-task [ pop-callbacks ] [ 2drop ] if ;

: handle-timeout ( mx task -- )
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

M: read-task io-task-container drop mx-reads ;

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

M: write-task io-task-container drop mx-writes ;

: add-write-io-task ( port continuation -- )
    over port-handle mx get-global mx-writes at*
    [ io-task-callbacks push drop ]
    [ drop <write-task> add-io-task ] if ;

: (wait-to-write) ( port -- )
    [ add-write-io-task stop ] callcc0 drop ;

M: port port-flush ( port -- )
    dup buffer-empty? [ drop ] [ (wait-to-write) ] if ;

M: unix-io io-multiplex ( ms -- )
    mx get-global unix-io-multiplex ;

M: unix-io init-stdio ( -- )
    0 1 handle>duplex-stream io:stdio set-global
    2 <writer> io:stderr set-global ;

! mx io-task for embedding an fd-based mx inside another mx
TUPLE: mx-port mx ;

: <mx-port> ( mx -- port )
    dup mx-fd f <port>
    mx-port over set-port-type
    { set-mx-port-mx set-delegate } mx-port construct ;

TUPLE: mx-task ;

: <mx-task> ( port -- task )
    f io-task construct-boa mx-task construct-delegate ;

M: mx-task do-io-task
    io-task-port mx-port-mx 0 swap unix-io-multiplex f ;

: multiplexer-error ( n -- )
    0 < [ err_no ignorable-error? [ (io-error) ] unless ] when ;
