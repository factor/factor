! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien generic assocs kernel kernel.private math
io.ports sequences strings structs sbufs threads unix
vectors io.buffers io.backend io.encodings math.parser
continuations system libc qualified namespaces io.timeouts
io.encodings.utf8 accessors inspector combinators ;
QUALIFIED: io
IN: io.unix.backend

! I/O tasks
GENERIC: handle-fd ( handle -- fd )

M: integer handle-fd ;

! I/O multiplexers
TUPLE: mx fd reads writes ;

: new-mx ( class -- obj )
    new
        H{ } clone >>reads
        H{ } clone >>writes ; inline

GENERIC: add-input-callback ( thread fd mx -- )

: add-callback ( thread fd assoc -- )
    [ ?push ] change-at ;

M: mx add-input-callback reads>> add-callback ;

GENERIC: add-output-callback ( thread fd mx -- )

M: mx add-output-callback writes>> add-callback ;

GENERIC: remove-input-callbacks ( fd mx -- callbacks )

M: mx remove-input-callbacks reads>> delete-at* drop ;

GENERIC: remove-output-callbacks ( fd mx -- callbacks )

M: mx remove-output-callbacks writes>> delete-at* drop ;

GENERIC: wait-for-events ( ms mx -- )

TUPLE: unix-io-error error port ;

: report-error ( error port -- )
    tuck unix-io-error boa >>error drop ;

: input-available ( fd mx -- )
    remove-input-callbacks [ resume ] each ;

: output-available ( fd mx -- )
    remove-output-callbacks [ resume ] each ;

TUPLE: io-timeout ;

M: io-timeout summary drop "I/O operation timed out" ;

M: unix cancel-io ( port -- )
    io-timeout new over report-error
    handle>> handle-fd mx get-global
    [ input-available ] [ output-available ] 2bi ;

SYMBOL: +retry+ ! just try the operation again without blocking
SYMBOL: +input+
SYMBOL: +output+

: wait-for-port ( port event -- )
    dup +retry+ eq? [ 2drop ] [
        [
            [
                >r
                swap handle>> handle-fd
                mx get-global
                r> {
                    { +input+ [ add-input-callback ] }
                    { +output+ [ add-output-callback ] }
                } case
            ] curry "I/O" suspend drop
        ] curry with-timeout pending-error
    ] if ;

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

M: integer close-handle ( fd -- ) close-file ;

! Readers
: eof ( reader -- )
    dup buffer>> buffer-empty? [ t >>eof ] when drop ;

: (refill) ( port -- n )
    [ handle>> ]
    [ buffer>> buffer-end ]
    [ buffer>> buffer-capacity ] tri read ;

! Returns an event to wait for which will ensure completion of
! this request
GENERIC: refill ( port handle -- event/f )

M: integer refill
    over buffer>> [ buffer-end ] [ buffer-capacity ] bi read
    {
        { [ dup 0 = ] [ drop eof f ] }
        { [ dup 0 > ] [ swap buffer>> n>buffer f ] }
        { [ err_no EINTR = ] [ 2drop +retry+ ] }
        { [ err_no EAGAIN = ] [ 2drop +input+ ] }
        [ (io-error) ]
    } cond ;

M: unix (wait-to-read) ( port -- )
    dup dup handle>> refill dup
    [ dupd wait-for-port (wait-to-read) ] [ 2drop ] if ;

! Writers
GENERIC: drain ( port handle -- event/f )

M: integer drain
    over buffer>> [ buffer@ ] [ buffer-length ] bi write
    {
        { [ dup 0 >= ] [
            over buffer>> buffer-consume
            buffer>> buffer-empty? f +output+ ?
        ] }
        { [ err_no EINTR = ] [ 2drop +retry+ ] }
        { [ err_no EAGAIN = ] [ 2drop +output+ ] }
        [ (io-error) ]
    } cond ;

M: unix (wait-to-write) ( port -- )
    dup dup handle>> drain dup
    [ dupd wait-for-port (wait-to-write) ] [ 2drop ] if ;

M: unix io-multiplex ( ms/f -- )
    mx get-global wait-for-events ;

M: unix (init-stdio) ( -- )
    0 <input-port>
    1 <output-port>
    2 <output-port> ;

! mx io-task for embedding an fd-based mx inside another mx
TUPLE: mx-port < port mx ;

: <mx-port> ( mx -- port )
    dup fd>> mx-port <port> swap >>mx ;

: multiplexer-error ( n -- )
    0 < [
        err_no [ EAGAIN = ] [ EINTR = ] bi or [ (io-error) ] unless
    ] when ;

: ?flag ( n mask symbol -- n )
    pick rot bitand 0 > [ , ] [ drop ] if ;
