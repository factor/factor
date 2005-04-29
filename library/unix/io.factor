! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: errors generic hashtables kernel lists math
sequences streams strings threads unix-internals vectors ;

! We want namespaces::bind to shadow the bind system call from
! unix-internals
USING: namespaces ;

! Some general stuff
: file-mode OCT: 0600 ;

: io-error ( n -- ) 0 < [ errno strerror throw ] when ;

: init-handle ( fd -- )
    F_SETFL O_NONBLOCK 1 fcntl io-error ;

! Common delegate of native stream readers and writers
TUPLE: port handle buffer error ;

C: port ( handle buffer -- port )
    [
        >r dup 0 > [ <buffer> ] [ drop f ] ifte r> set-delegate
    ] keep
    [ >r dup init-handle r> set-port-handle ] keep ;

M: port stream-close ( port -- )
    dup port-handle close
    delegate [ buffer-free ] when* ;

: buffered-port 8192 <port> ;

: >port< dup port-handle swap delegate ;

: pending-error ( reader -- ) port-error throw ;

: postpone-error ( reader -- )
    errno strerror swap set-port-error ;

! Associates a port with a list of continuations waiting on the
! port to finish I/O
TUPLE: io-task port callbacks ;
C: io-task ( port -- ) [ set-io-task-port ] keep ;

! Multiplexer
GENERIC: do-io-task ( task -- ? )
GENERIC: io-task-events ( task -- events )

! A hashtable in the global namespace mapping fd numbers to
! io-tasks. This is not a vector, since we need a quick way
! to find the number of elements, and a hashtable gives us
! this with the hash-size call.
SYMBOL: io-tasks

: io-task-fd io-task-port port-handle ;

: add-io-task ( callback task -- )
    [ >r unit r> set-io-task-callbacks ] keep
    dup io-task-fd io-tasks get 2dup hash [
        "Cannot perform multiple I/O ops on the same port" throw
    ] when set-hash ;

: remove-io-task ( task -- )
    io-task-fd io-tasks get remove-hash ;

: pop-callback ( task -- callback )
    dup io-task-callbacks uncons dup [
        rot set-io-task-callbacks
    ] [
        drop swap remove-io-task
    ] ifte ;

: handle-fd ( fd -- quot )
    io-tasks get hash dup do-io-task [
        pop-callback
    ] [
        drop f
    ] ifte ;

: do-io-tasks ( pollfds n -- )
    [
        dup pick pollfd-nth dup pollfd-revents 0 = [
            drop
        ] [
            pollfd-fd handle-fd [ call ] when*
        ] ifte
    ] repeat drop ;

: init-pollfd ( task pollfd -- )
    over io-task-fd over set-pollfd-fd
    swap io-task-events swap set-pollfd-events ;

: make-pollfds ( -- pollfds n )
    io-tasks get dup hash-size [
        swap >r <pollfd-array> 0 swap r> hash-values [
            ( n pollfds iotask )
            pick pick pollfd-nth init-pollfd >r 1 + r>
        ] each nip
    ] keep ;

: io-multiplex ( -- )
    make-pollfds 2dup -1 poll drop do-io-tasks io-multiplex ;

! Readers

: open-read ( path -- fd )
    O_RDONLY file-mode open dup io-error ;

! The cr slot is set to true by read-line-loop if the last
! character read was \r.
TUPLE: reader line ready? cr ;

C: reader ( handle -- reader )
    [ >r buffered-port r> set-delegate ] keep ;

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

: read-line-step ( reader -- ? )
    [ read-line-loop dup ] keep set-reader-ready? ;

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

: refill ( port -- )
    dup buffer-length 0 = [
        >port<
        tuck dup buffer-end swap buffer-capacity read
        dup 0 >= [ swap n>buffer ] [ drop postpone-error ] ifte
    ] [
        drop
    ] ifte ;

: eof? ( buffer -- ? ) buffer-fill 0 = ;

TUPLE: read-line-task ;

C: read-line-task ( port -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: read-line-task do-io-task ( task -- ? )
    io-task-port dup refill dup eof? [
        reader-eof t
    ] [
        read-line-step
    ] ifte ;

M: read-line-task io-task-events ( task -- events )
    drop read-events ;

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
    dup buffer-length 1 >= over reader-cr and [
        dup buffer-peek CHAR: \n = [
            1 swap buffer-consume
        ] [
            drop
        ] ifte
    ] [
        drop
    ] ifte ;

! Reading character counts
: read-loop ( count reader -- ? )
    dup trailing-cr
    dup reader-line -rot >r over length - ( remaining) r>
    2dup buffer-length <= [
        buffer> nappend t
    ] [
        buffer>> nip nappend f
    ] ifte ;

: read-step ( count reader -- ? )
    [ read-loop dup ] keep set-reader-ready? ;

: can-read-count? ( count reader -- ? )
    dup pending-error
    2dup init-reader
    2dup reader-line length <= [
        t swap set-reader-ready? drop t
    ] [
        read-step
    ] ifte ;

TUPLE: read-task count ;

C: read-task ( count port -- task )
    [ >r <io-task> r> set-delegate ] keep
    [ set-read-task-count ] keep ;

: >read-task< dup read-task-count swap io-task-port ;

M: read-task do-io-task ( task -- ? )
    >read-task< dup refill dup eof? [
        nip reader-eof t
    ] [
        read-step
    ] ifte ;

M: read-task io-task-events ( task -- events )
    drop read-events ;

: wait-to-read ( count port -- )
    2dup can-read-count? [
        [ -rot <read-task> add-io-task stop ] callcc0 
    ] unless 2drop ;

M: reader stream-read ( count stream -- string )
    [ wait-to-read ] keep read-fin ;

! Writers

: open-write ( path -- fd )
    O_WRONLY O_CREAT bitor O_TRUNC bitor file-mode open
    dup io-error ;

TUPLE: writer ;

C: writer ( fd -- writer )
    [ >r buffered-port r> set-delegate ] keep ;

: write-step ( fd buffer -- )
    tuck dup buffer@ swap buffer-length write dup 0 >= [
        swap buffer-consume
    ] [
        drop postpone-error
    ] ifte ;

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

C: write-task ( port -- task )
    [ >r <io-task> r> set-delegate ] keep ;

M: write-task do-io-task
    io-task-port dup buffer-length 0 = over port-error or [
        0 swap buffer-reset t
    ] [
        >port< write-step f
    ] ifte ;

M: write-task io-task-events ( task -- events )
    drop write-events ;

: write-fin ( str writer -- )
    dup pending-error >buffer ;

: add-write-io-task ( callback task -- )
    dup io-task-fd io-tasks get hash [
        dup write-task? [
            [
                nip io-task-callbacks cons
            ] keep set-io-task-callbacks
        ] [
            drop add-io-task
        ] ifte
    ] [
        add-io-task
    ] ifte* ;

M: writer stream-flush ( stream -- )
    [
        swap <write-task> add-write-io-task stop
    ] callcc0 drop ;

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

! Copying from a reader to a writer

: can-copy? ( from -- ? )
    dup eof? [ refill ] [ drop t ] ifte ;

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

USE: stdio

: init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        <namespace> io-tasks set
        0 1 t <fd-stream> stdio set
    ] bind ;

IN: streams

: fcopy 2drop ;
