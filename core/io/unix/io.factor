! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien bit-arrays errors generic assocs io
kernel kernel-internals math nonblocking-io sequences strings
sbufs threads unix-internals vectors buffers ;
IN: io-internals

! We want namespaces::bind to shadow the bind system call from
! unix-internals
USING: namespaces ;

! Global variables
SYMBOL: read-fdset
SYMBOL: read-tasks
SYMBOL: write-fdset
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
C: io-task ( port -- task )
    [ set-io-task-port ] keep
    V{ } clone over set-io-task-callbacks ;

: delegate>io-task >r <io-task> r> set-delegate ;

! Multiplexer
GENERIC: do-io-task ( task -- ? )
GENERIC: task-container ( task -- vector )

: io-task-fd io-task-port port-handle ;

: add-io-task ( callback task -- )
    [ io-task-callbacks push ] keep
    dup io-task-fd over task-container 2dup at [
        "Cannot perform multiple reads from the same port" throw
    ] when set-at ;

: remove-io-task ( task -- )
    dup io-task-fd swap task-container delete-at ;

: pop-callbacks ( task -- )
    dup io-task-callbacks swap remove-io-task
    [ schedule-thread ] each ;

: handle-fd ( task -- )
    dup io-task-port touch-port
    dup do-io-task [ pop-callbacks ] [ drop ] if ;

: handle-fdset ( fdset tasks -- )
    [
        nip dup io-task-port timeout? [
            dup io-task-port "Timeout" swap report-error
            nip pop-callbacks
        ] [
            tuck io-task-fd swap nth
            [ handle-fd ] [ drop ] if
        ] if
    ] assoc-each-with ;

: init-fdset ( fdset tasks -- )
    >r dup clear-bits r>
    [ drop t swap rot set-nth ] assoc-each-with ;

: read-fdset/tasks
    read-fdset get-global read-tasks get-global ;

: write-fdset/tasks
    write-fdset get-global write-tasks get-global ;

: init-fdsets ( -- read write except )
    read-fdset/tasks dupd init-fdset
    write-fdset/tasks dupd init-fdset
    f ;

: (io-multiplex) ( ms -- )
    [ FD_SETSIZE init-fdsets ] keep make-timeval select 0 < [
        err_no ignorable-error? [ (io-multiplex) ] [ drop ] if
    ] [
        drop
    ] if ;

: io-multiplex ( ms -- )
    (io-multiplex)
    read-fdset/tasks handle-fdset
    write-fdset/tasks handle-fdset ;

! Readers
: open-read ( path -- fd )
    O_RDONLY file-mode open dup io-error ;

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

C: read-task ( port -- task )
    swap <io-task> over set-delegate ;

M: read-task do-io-task
    io-task-port dup refill
    [ [ reader-eof ] [ drop ] if ] keep ;

M: read-task task-container drop read-tasks get-global ;

M: input-port (wait-to-read)
    [ swap <read-task> add-io-task stop ] callcc0
    pending-error ;

! Writers
: open-write ( path -- fd )
    O_WRONLY O_CREAT bitor O_TRUNC bitor file-mode open
    dup io-error ;

: write-step ( port -- ? )
    dup port-handle over buffer@ pick buffer-length write
    dup 0 >= [ swap buffer-consume f ] [ drop defer-error ] if ;

TUPLE: write-task ;

C: write-task ( port -- task ) [ delegate>io-task ] keep ;

M: write-task do-io-task
    io-task-port dup buffer-length zero? over port-error or
    [ 0 swap buffer-reset t ] [ write-step ] if ;

M: write-task task-container drop write-tasks get-global ;

: add-write-io-task ( callback task -- )
    dup io-task-fd write-tasks get-global at
    [ io-task-callbacks push ] [ add-io-task ] ?if ;

: (wait-to-write) ( port -- )
    [ swap <write-task> add-write-io-task stop ] callcc0 drop ;

: port-flush ( port -- )
    dup buffer-empty? [ drop ] [ (wait-to-write) ] if ;

M: output-port stream-flush
    dup port-flush pending-error ;

M: port stream-close
    dup port-type closed eq? [
        dup port-type >r closed over set-port-type r>
        output eq? [ dup port-flush ] when
        dup port-handle close
        dup delegate [ buffer-free ] when*
        f over set-delegate
    ] unless drop ;

! Make a duplex stream for reading/writing a pair of fds
: open-r/w ( path -- fd ) O_RDWR file-mode open dup io-error ;

: <fd-stream> ( infd outfd -- stream )
    >r <reader> r> <writer> <duplex-stream> ;

USE: io

: init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        H{ } clone read-tasks set
        FD_SETSIZE 8 * <bit-array> read-fdset set
        H{ } clone write-tasks set
        FD_SETSIZE 8 * <bit-array> write-fdset set
    ] bind ;

: init-stdio ( -- )
    0 1 <fd-stream> stdio set ;
