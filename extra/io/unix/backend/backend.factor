! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien generic assocs kernel kernel.private math
io.nonblocking sequences strings structs sbufs threads unix.ffi unix
vectors io.buffers io.backend io.encodings math.parser
continuations system libc qualified namespaces io.timeouts
io.encodings.utf8 accessors ;
QUALIFIED: io
IN: io.unix.backend

! I/O tasks
TUPLE: io-task port callbacks ;

: io-task-fd port>> handle>> ;

: <io-task> ( port continuation/f class -- task )
    new
        swap [ 1vector ] [ V{ } clone ] if* >>callbacks
        swap >>port ; inline

TUPLE: input-task < io-task ;

TUPLE: output-task < io-task ;

GENERIC: do-io-task ( task -- ? )
GENERIC: io-task-container ( mx task -- hashtable )

! I/O multiplexers
TUPLE: mx fd reads writes ;

M: input-task io-task-container drop reads>> ;

M: output-task io-task-container drop writes>> ;

: new-mx ( class -- obj )
    new
        H{ } clone >>reads
        H{ } clone >>writes ; inline

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

: check-errno ( -- )
    err_no dup zero? [ drop ] [ strerror throw ] if ;

: check-null ( n -- ) zero? [ (io-error) ] when ;

: io-error ( n -- ) 0 < [ (io-error) ] when ;
 
M: integer init-handle ( fd -- )
    #! We drop the error code rather than calling io-error,
    #! since on OS X 10.3, this operation fails from init-io
    #! when running the Factor.app (presumably because fd 0 and
    #! 1 are closed).
    [ F_SETFL O_NONBLOCK fcntl drop ]
    [ F_SETFD FD_CLOEXEC fcntl drop ] bi ;

M: integer close-handle ( fd -- )
    close ;

: report-error ( error port -- )
    [ "Error on fd " % dup handle>> # ": " % swap % ] "" make
    >>error drop ;

: ignorable-error? ( n -- ? )
    [ EAGAIN number= ] [ EINTR number= ] bi or ;

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
        "I/O operation cancelled" over port>> report-error
        pop-callbacks
    ] [
        2drop
    ] if ;

: cancel-io-tasks ( port mx -- )
    [ dup reads>> handle-timeout ]
    [ dup writes>> handle-timeout ] 2bi ;

M: unix cancel-io ( port -- )
    mx get-global cancel-io-tasks ;

! Readers
: reader-eof ( reader -- )
    dup buffer>> buffer-empty? [ t >>eof ] when drop ;

: (refill) ( port -- n )
    [ handle>> ]
    [ buffer>> buffer-end ]
    [ buffer>> buffer-capacity ] tri read ;

: refill ( port -- ? )
    #! Return f if there is a recoverable error
    dup buffer>> buffer-empty? [
        dup (refill)  dup 0 >= [
            swap buffer>> n>buffer t
        ] [
            drop defer-error
        ] if
    ] [
        drop t
    ] if ;

TUPLE: read-task < input-task ;

: <read-task> ( port continuation -- task )
    read-task <io-task> ;

M: read-task do-io-task
    io-task-port dup refill
    [ [ reader-eof ] [ drop ] if ] keep ;

M: unix (wait-to-read)
    [ <read-task> add-io-task ] with-port-continuation
    pending-error ;

! Writers
: write-step ( port -- ? )
    dup
    [ handle>> ]
    [ buffer>> buffer@ ]
    [ buffer>> buffer-length ] tri
    write dup 0 >=
    [ swap buffer>> buffer-consume f ]
    [ drop defer-error ] if ;

TUPLE: write-task < output-task ;

: <write-task> ( port continuation -- task )
    write-task <io-task> ;

M: write-task do-io-task
    io-task-port dup [ buffer>> buffer-empty? ] [ port-error ] bi or
    [ 0 swap buffer>> buffer-reset t ] [ write-step ] if ;

: add-write-io-task ( port continuation -- )
    over handle>> mx get-global writes>> at*
    [ io-task-callbacks push drop ]
    [ drop <write-task> add-io-task ] if ;

: (wait-to-write) ( port -- )
    [ add-write-io-task ] with-port-continuation drop ;

M: unix flush-port ( port -- )
    dup buffer>> buffer-empty? [ drop ] [ (wait-to-write) ] if ;

M: unix io-multiplex ( ms/f -- )
    mx get-global wait-for-events ;

M: unix (init-stdio) ( -- )
    0 <reader>
    1 <writer>
    2 <writer> ;

! mx io-task for embedding an fd-based mx inside another mx
TUPLE: mx-port < port mx ;

: <mx-port> ( mx -- port )
    dup fd>> mx-port <port> swap >>mx ;

TUPLE: mx-task < io-task ;

: <mx-task> ( port -- task )
    f mx-task <io-task> ;

M: mx-task do-io-task
    port>> mx>> 0 swap wait-for-events f ;

: multiplexer-error ( n -- )
    0 < [ err_no ignorable-error? [ (io-error) ] unless ] when ;

: ?flag ( n mask symbol -- n )
    pick rot bitand 0 > [ , ] [ drop ] if ;
