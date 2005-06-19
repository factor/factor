! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: alien assembler errors generic hashtables kernel
kernel-internals lists math sequences streams strings threads
unix-internals unparser vectors ;

! We want namespaces::bind to shadow the bind system call from
! unix-internals
USING: namespaces ;

! This will go elsewhere soon
: byte-bit ( n alien -- byte bit )
    over -5 shift alien-unsigned-4 swap 31 bitand ;

: bit-length ( n -- n ) cell / ceiling ;

: <bit-array> ( n -- array )
    bit-length <byte-array> ;

: bit-nth ( n alien -- ? )
    byte-bit 1 swap shift bitand 0 > ;

: set-bit ( ? byte bit -- byte )
    1 swap shift rot [ bitor ] [ bitnot bitand ] ifte ;

: set-bit-nth ( ? n alien -- )
    [ byte-bit set-bit ] 2keep
    swap -5 shift set-alien-unsigned-4 ;

: clear-bits ( alien len -- )
    bit-length [
        0 pick pick set-alien-unsigned-cell
    ] repeat drop ;

! Global variables
SYMBOL: read-fdset
SYMBOL: read-tasks
SYMBOL: write-fdset
SYMBOL: write-tasks

! Some general stuff
: file-mode OCT: 0600 ;

: (io-error) err_no strerror throw ;

: check-null ( n -- ) 0 = [ (io-error) ] when ;

: io-error ( n -- ) 0 < [ (io-error) ] when ;

: init-handle ( fd -- ) F_SETFL O_NONBLOCK fcntl io-error ;

! Common delegate of native stream readers and writers
TUPLE: port handle buffer error timeout cutoff ;

: make-buffer ( n -- buffer/f )
    dup 0 > [ <buffer> ] [ drop f ] ifte ;

C: port ( handle buffer -- port )
    [ 0 swap set-port-timeout ] keep
    [ 0 swap set-port-cutoff ] keep
    [ >r make-buffer r> set-delegate ] keep
    [ >r dup init-handle r> set-port-handle ] keep ;

M: port stream-close ( port -- )
    dup port-handle close
    delegate [ buffer-free ] when* ;

: touch-port ( port -- )
    dup port-timeout dup 0 = [
        2drop
    ] [
        millis + swap set-port-cutoff
    ] ifte ;

M: port set-timeout ( timeout port -- )
    [ set-port-timeout ] keep touch-port ;

: buffered-port 8192 <port> ;

: >port< dup port-handle swap delegate ;

: pending-error ( port -- )
    dup port-error f rot set-port-error throw ;

: EAGAIN 11 ;
: EINTR 4 ;

: defer-error ( port -- ? )
    #! Return t if it is an unrecoverable error.
    err_no dup EAGAIN = over EINTR = or [
        2drop f
    ] [
        [
            "Error on fd " % over port-handle unparse %
            ": " % strerror %
        ] make-string swap set-port-error  t
    ] ifte ;

! Associates a port with a list of continuations waiting on the
! port to finish I/O
TUPLE: io-task port callbacks ;
C: io-task ( port -- ) [ set-io-task-port ] keep ;

! Multiplexer
GENERIC: do-io-task ( task -- ? )
GENERIC: task-container ( task -- vector )

: io-task-fd io-task-port port-handle ;

: add-io-task ( callback task -- )
    [ >r unit r> set-io-task-callbacks ] keep
    dup io-task-fd over task-container 2dup hash [
        "Cannot perform multiple I/O ops on the same port" throw
    ] when set-hash ;

: remove-io-task ( task -- )
    dup io-task-fd swap task-container remove-hash ;

: pop-callback ( task -- callback )
    dup io-task-callbacks uncons dup [
        rot set-io-task-callbacks
    ] [
        drop swap remove-io-task
    ] ifte ;

: handle-fd ( task -- )
    dup do-io-task [
        dup io-task-port touch-port pop-callback [ call ] when*
    ] [
        drop
    ] ifte ;

: timeout? ( port -- ? )
    port-cutoff dup 0 = not swap millis < and ;

: handle-fd? ( fdset task -- ? )
    dup io-task-port timeout? [
        2drop t
    ] [
        io-task-fd swap bit-nth
    ] ifte ;

: handle-fdset ( fdset tasks -- )
    [
        cdr tuck handle-fd? [ handle-fd ] [ drop ] ifte
    ] hash-each-with ;

: init-fdset ( fdset tasks -- )
    >r dup FD_SETSIZE clear-bits r>
    [ car t swap rot set-bit-nth ] hash-each-with ;

: init-fdsets ( -- read write except )
    read-fdset get [ read-tasks get init-fdset ] keep
    write-fdset get [ write-tasks get init-fdset ] keep
    NULL ;

: io-multiplex ( timeout -- )
    >r FD_SETSIZE init-fdsets r> make-timeval select drop
    read-fdset get read-tasks get handle-fdset
    write-fdset get write-tasks get handle-fdset ;

! Readers

: open-read ( path -- fd )
    O_RDONLY file-mode open dup io-error ;

! The cr slot is set to true by read-line-loop if the last
! character read was \r.
TUPLE: reader line cr ;

C: reader ( handle -- reader )
    [ >r buffered-port r> set-delegate ] keep ;

: pop-line ( reader -- sbuf/f )
    dup pending-error [ reader-line f ] keep set-reader-line ;

: read-fin ( reader -- str ) pop-line dup [ >string ] when ;

: reader-cr> ( reader -- ? )
    dup reader-cr >r f swap set-reader-cr r> ;

! Reading lines
: read-line-char ( reader ch -- )
    f pick set-reader-cr  swap reader-line push ;

: read-line-loop ( reader -- ? )
    dup buffer-length 0 = [
        drop f
    ] [
        dup buffer-pop
        dup CHAR: \r = [
            drop t swap set-reader-cr t
        ] [
            dup CHAR: \n = [
                drop dup reader-cr> [
                    read-line-loop
                ] [
                    drop t
                ] ifte
            ] [
                dupd read-line-char read-line-loop
            ] ifte
        ] ifte
    ] ifte ;

: init-reader ( count reader -- ) >r <sbuf> r> set-reader-line ;

: can-read-line? ( reader -- ? )
    dup pending-error 80 over init-reader read-line-loop ;

: reader-eof ( reader -- )
    dup reader-line empty? [
        f swap set-reader-line
    ] [
        drop
    ] ifte ;

: (refill) ( port -- n )
    >port< dup buffer-end swap buffer-capacity read ;

: refill ( port -- ? )
    #! Return f if there is a recoverable error
    dup buffer-length 0 = [
        dup (refill)  dup 0 >= [
            swap n>buffer t
        ] [
            drop defer-error
        ] ifte
    ] [
        drop t
    ] ifte ;

TUPLE: read-line-task ;

C: read-line-task ( port -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: read-line-task do-io-task ( task -- ? )
    io-task-port dup refill [
        dup eof? [
            reader-eof t
        ] [
            read-line-loop
        ] ifte
    ] [
        drop f
    ] ifte ;

M: read-line-task task-container drop read-tasks get ;

: wait-to-read-line ( port -- )
    dup can-read-line? [
        [ swap <read-line-task> add-io-task stop ] callcc0
    ] unless drop ;

M: reader stream-readln ( stream -- line )
    dup wait-to-read-line read-fin ;

: trailing-cr ( reader -- )
    #! Handle a corner case. If the previous request was a line
    #! read and the line ends with \r\n, the reader stopped
    #! reading at \r and set the reader-cr flag to true. But we
    #! must ignore the \n.
    dup buffer-length 1 >= [
        dup reader-cr [
            dup buffer-peek CHAR: \n = [
                1 swap buffer-consume
            ] [
                drop
            ] ifte
        ] [
            drop
        ] ifte
    ] [
        drop
    ] ifte ;

! Reading character counts
: read-step ( count reader -- ? )
    dup trailing-cr
    dup reader-line -rot >r over length - ( remaining) r>
    2dup buffer-length <= [
        buffer> nappend t
    ] [
        buffer>> nip nappend f
    ] ifte ;

: can-read-count? ( count reader -- ? )
    dup pending-error 2dup init-reader read-step ;

TUPLE: read-task count ;

C: read-task ( count port -- task )
    [ >r <io-task> r> set-delegate ] keep
    [ set-read-task-count ] keep ;

: >read-task< dup read-task-count swap io-task-port ;

M: read-task do-io-task ( task -- ? )
    >read-task< dup refill [
        dup eof? [
            reader-eof drop t
        ] [
            read-step
        ] ifte
    ] [
        2drop f
    ] ifte ;

M: read-task task-container drop read-tasks get ;

: wait-to-read ( count port -- )
    2dup can-read-count? [
        [ -rot <read-task> add-io-task stop ] callcc0 
    ] unless 2drop ;

M: reader stream-read ( count stream -- string )
    [ wait-to-read ] keep read-fin ;

M: reader stream-read1 ( stream -- string )
    1 over wait-to-read reader-line first ;

! Writers

: open-write ( path -- fd )
    O_WRONLY O_CREAT bitor O_TRUNC bitor file-mode open
    dup io-error ;

TUPLE: writer ;

C: writer ( fd -- writer )
    [ >r buffered-port r> set-delegate ] keep ;

: write-step ( port -- )
    dup >port< dup buffer@ swap buffer-length write dup 0 >= [
        swap buffer-consume
    ] [
        drop defer-error drop
    ] ifte ;

: can-write? ( len writer -- ? )
    #! If the buffer is empty and the string is too long,
    #! extend the buffer.
    dup pending-error
    dup eof? [
        2drop t
    ] [
        [ buffer-fill + ] keep buffer-capacity <=
    ] ifte ;

TUPLE: write-task ;

C: write-task ( port -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: write-task do-io-task
    io-task-port dup buffer-length 0 = over port-error or [
        0 swap buffer-reset t
    ] [
        write-step f
    ] ifte ;

M: write-task task-container drop write-tasks get ;

: write-fin ( str writer -- )
    dup pending-error >buffer ;

: add-write-io-task ( callback task -- )
    dup io-task-fd write-tasks get hash [
        dup write-task? [
            [ nip io-task-callbacks cons ] keep
            set-io-task-callbacks
        ] [
            drop add-io-task
        ] ifte
    ] [
        add-io-task
    ] ifte* ;

M: writer stream-flush ( stream -- )
    [ swap <write-task> add-write-io-task stop ] callcc0 drop ;

M: writer stream-auto-flush ( stream -- ) drop ;

: wait-to-write ( len port -- )
    tuck can-write? [ drop ] [ stream-flush ] ifte ;

: blocking-write ( str writer -- )
    over length over wait-to-write write-fin ;

M: writer stream-write-attr ( string style writer -- )
    nip >r dup string? [ ch>string ] unless r> blocking-write ;

M: writer stream-close ( stream -- )
    dup stream-flush delegate stream-close ;

! Make a duplex stream for reading/writing a pair of fds
: <fd-stream> ( infd outfd flush? -- stream )
    >r >r <reader> r> <writer> r> <duplex-stream> ;

: idle-io-task ( -- )
    [ schedule-thread 10 io-multiplex stop ] callcc0
    idle-io-task ;

USE: stdio

: init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        <namespace> read-tasks set
        FD_SETSIZE <bit-array> read-fdset set
        <namespace> write-tasks set
        FD_SETSIZE <bit-array> write-fdset set
        0 1 t <fd-stream> stdio set
    ] bind
    [ idle-io-task ] in-thread ;
