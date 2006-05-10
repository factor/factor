! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io-internals
USING: alien arrays errors generic hashtables io kernel
kernel-internals lists math parser queues sequences strings
threads unix-internals vectors words ;

! We want namespaces::bind to shadow the bind system call from
! unix-internals
USING: namespaces ;

! This will go elsewhere soon
: byte-bit ( n alien -- byte bit )
    over -5 shift alien-unsigned-4 swap 31 bitand ;

: bit-nth ( n alien -- ? )
    byte-bit 1 swap shift bitand 0 > ;

: set-bit ( ? byte bit -- byte )
    1 swap shift rot [ bitor ] [ bitnot bitand ] if ;

: set-bit-nth ( ? n alien -- )
    [ byte-bit set-bit ] 2keep
    swap -5 shift set-alien-unsigned-4 ;

: clear-bits ( alien len -- )
    [ 0 -rot set-alien-unsigned-1 ] each-with ;

! Global variables
SYMBOL: read-fdset
SYMBOL: read-tasks
SYMBOL: write-fdset
SYMBOL: write-tasks

! Some general stuff
: file-mode OCT: 0600 ;

: (io-error) err_no strerror throw ;

: check-null ( n -- ) zero? [ (io-error) ] when ;

: io-error ( n -- ) 0 < [ (io-error) ] when ;

: init-handle ( fd -- ) F_SETFL O_NONBLOCK fcntl io-error ;

! Common delegate of native stream readers and writers
SYMBOL: input
SYMBOL: output
SYMBOL: closed

TUPLE: port handle error timeout cutoff type sbuf eof? ;

: check-port ( port expected -- )
    >r port-type r> 2dup eq? [
        [
            "Cannot perform " % word-name %
            " on " % word-name % " port" %
        ] "" make throw
    ] unless 2drop ;

C: port ( handle buffer -- port )
    [ set-delegate ] keep
    [ >r dup init-handle r> set-port-handle ] keep
    [ 0 swap set-port-timeout ] keep
    [ 0 swap set-port-cutoff ] keep
    80 <sbuf> over set-port-sbuf ;

: touch-port ( port -- )
    dup port-timeout dup zero?
    [ 2drop ] [ millis + swap set-port-cutoff ] if ;

M: port set-timeout ( timeout port -- )
    [ set-port-timeout ] keep touch-port ;

: buffered-port 8192 <buffer> <port> ;

: >port< dup port-handle swap delegate ;

: pending-error ( port -- )
    dup port-error f rot set-port-error [ throw ] when* ;

: report-error ( error port -- )
    [ "Error on fd " % dup port-handle # ": " % swap % ] "" make
    swap set-port-error ;

: defer-error ( port -- ? )
    #! Return t if it is an unrecoverable error.
    err_no dup EAGAIN = over EINTR = or
    [ 2drop f ] [ strerror swap report-error t ] if ;

! Associates a port with a list of continuations waiting on the
! port to finish I/O
TUPLE: io-task port callbacks ;
C: io-task ( port -- )
    [ set-io-task-port ] keep
    <queue> over set-io-task-callbacks ;

! Multiplexer
GENERIC: do-io-task ( task -- ? )
GENERIC: task-container ( task -- vector )

: io-task-fd io-task-port port-handle ;

: add-io-task ( callback task -- )
    [ >r <queue> [ enque ] keep r> set-io-task-callbacks ] keep
    dup io-task-fd over task-container 2dup hash [
        "Cannot perform multiple reads from the same port" throw
    ] when set-hash ;

: remove-io-task ( task -- )
    dup io-task-fd swap task-container remove-hash ;

: pop-callback ( task -- callback )
    dup io-task-callbacks dup deque >r
    queue-empty? [ remove-io-task ] [ drop ] if r> ;

: handle-fd ( task -- )
    dup io-task-port touch-port dup do-io-task
    [ pop-callback continue ] [ drop ] if ;

: timeout? ( port -- ? )
    port-cutoff dup zero? not swap millis < and ;

: handle-fdset ( fdset tasks -- )
    [
        nip dup io-task-port timeout? [
            dup io-task-port "Timeout" swap report-error
            nip pop-callback continue
        ] [
            tuck io-task-fd swap bit-nth
            [ handle-fd ] [ drop ] if
        ] if
    ] hash-each-with ;

: init-fdset ( fdset tasks -- )
    >r dup FD_SETSIZE clear-bits r>
    [ drop t swap rot set-bit-nth ] hash-each-with ;

: init-fdsets ( -- read write except )
    read-fdset get-global
    [ read-tasks get-global init-fdset ] keep
    write-fdset get-global
    [ write-tasks get-global init-fdset ] keep
    f ;

: io-multiplex ( timeout -- )
    >r FD_SETSIZE init-fdsets r> make-timeval select io-error
    read-fdset get-global read-tasks get-global handle-fdset
    write-fdset get-global write-tasks get-global handle-fdset ;

! Readers

: <reader> ( fd -- stream )
    buffered-port input over set-port-type <line-reader> ;

: open-read ( path -- fd )
    O_RDONLY file-mode open dup io-error ;

: reader-eof ( reader -- )
    dup port-sbuf empty? [ t swap set-port-eof? ] [ drop ] if ;

: (refill) ( port -- n )
    >port< dup buffer-end swap buffer-capacity read ;

: refill ( port -- ? )
    #! Return f if there is a recoverable error
    dup buffer-length zero? [
        dup (refill)  dup 0 >= [
            swap n>buffer t
        ] [
            drop defer-error
        ] if
    ] [
        drop t
    ] if ;

! Reading character counts
: read-step ( count reader -- ? )
    dup port-sbuf -rot >r over length - ( remaining) r>
    2dup buffer-length <= [
        buffer> nappend t
    ] [
        buffer>> nip nappend f
    ] if ;

: can-read-count? ( count reader -- ? )
    dup pending-error 0 over port-sbuf set-length read-step ;

TUPLE: read-task count ;

C: read-task ( count port -- task )
    [ >r <io-task> r> set-delegate ] keep
    [ set-read-task-count ] keep ;

: >read-task< dup read-task-count swap io-task-port ;

M: read-task do-io-task ( task -- ? )
    >read-task< dup refill [
        dup buffer-empty? [
            reader-eof drop t
        ] [
            read-step
        ] if
    ] [
        2drop f
    ] if ;

M: read-task task-container drop read-tasks get-global ;

: wait-to-read ( count port -- )
    2dup can-read-count? [
        [ -rot <read-task> add-io-task stop ] callcc0
    ] unless 2drop ;

M: port stream-read ( count stream -- string )
    dup input check-port
    [ wait-to-read ] keep dup port-eof?
    [ drop f ] [ port-sbuf >string ] if ;

M: port stream-read1 ( stream -- char/f )
    dup input check-port
    1 over wait-to-read dup port-eof?
    [ drop f ] [ port-sbuf first ] if ;

! Writers

: open-write ( path -- fd )
    O_WRONLY O_CREAT bitor O_TRUNC bitor file-mode open
    dup io-error ;

: <writer> ( fd -- writer )
    buffered-port output over set-port-type <plain-writer> ;

: write-step ( port -- )
    dup >port< dup buffer@ swap buffer-length write dup 0 >= [
        swap buffer-consume
    ] [
        drop defer-error drop
    ] if ;

: can-write? ( len writer -- ? )
    #! If the buffer is empty and the string is too long,
    #! extend the buffer.
    dup pending-error
    dup buffer-empty? [
        2drop t
    ] [
        [ buffer-fill + ] keep buffer-capacity <=
    ] if ;

TUPLE: write-task ;

C: write-task ( port -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: write-task do-io-task
    io-task-port dup buffer-length zero? over port-error or
    [ 0 swap buffer-reset t ] [ write-step f ] if ;

M: write-task task-container drop write-tasks get-global ;

: add-write-io-task ( callback task -- )
    dup io-task-fd write-tasks get-global hash
    [ io-task-callbacks enque ] [ add-io-task ] ?if ;

: port-flush ( port -- )
    [ swap <write-task> add-write-io-task stop ] callcc0 drop ;

M: port stream-flush ( stream -- )
    dup output check-port port-flush ;

: wait-to-write ( len port -- )
    tuck can-write? [ dup stream-flush ] unless pending-error ;

M: port stream-write1 ( char writer -- )
    dup output check-port 1 over wait-to-write ch>buffer ;

M: port stream-write ( string writer -- )
    dup output check-port
    over length over wait-to-write >buffer ;

M: port stream-close ( stream -- )
    dup port-type closed eq? [
        dup port-type >r closed over set-port-type r>
        output eq? [ dup port-flush ] when dup port-handle close
        dup delegate [ buffer-free ] when* f over set-delegate
    ] unless drop ;

! Make a duplex stream for reading/writing a pair of fds

: <fd-stream> ( infd outfd -- stream )
    >r <reader> r> <writer> <duplex-stream> ;

USE: io

: init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        H{ } clone read-tasks set
        FD_SETSIZE <byte-array> read-fdset set
        H{ } clone write-tasks set
        FD_SETSIZE <byte-array> write-fdset set
        0 1 <fd-stream> stdio set
    ] bind ;
