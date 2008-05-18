! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien generic assocs kernel kernel.private math
io.ports sequences strings structs sbufs threads unix
vectors io.buffers io.backend io.encodings math.parser
continuations system libc qualified namespaces io.timeouts
io.encodings.utf8 destructors accessors inspector combinators ;
QUALIFIED: io
IN: io.unix.backend

! I/O tasks
GENERIC: handle-fd ( handle -- fd )

TUPLE: fd fd disposed ;

: <fd> ( n -- fd )
    #! We drop the error code rather than calling io-error,
    #! since on OS X 10.3, this operation fails from init-io
    #! when running the Factor.app (presumably because fd 0 and
    #! 1 are closed).
    [ F_SETFL O_NONBLOCK fcntl drop ]
    [ F_SETFD FD_CLOEXEC fcntl drop ]
    [ f fd boa ]
    tri ;

M: fd dispose* fd>> close-file ;

M: fd handle-fd fd>> ;

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

: input-available ( fd mx -- )
    remove-input-callbacks [ resume ] each ;

: output-available ( fd mx -- )
    remove-output-callbacks [ resume ] each ;

M: unix cancel-io ( port -- )
    handle>> handle-fd mx get-global
    [ remove-input-callbacks [ t swap resume-with ] each ]
    [ remove-output-callbacks [ t swap resume-with ] each ]
    2bi ;

SYMBOL: +retry+ ! just try the operation again without blocking
SYMBOL: +input+
SYMBOL: +output+

: wait-for-fd ( handle event -- timeout? )
    dup +retry+ eq? [ 2drop f ] [
        [
            >r
            swap handle-fd
            mx get-global
            r> {
                { +input+ [ add-input-callback ] }
                { +output+ [ add-output-callback ] }
            } case
        ] curry "I/O" suspend nip
    ] if ;

ERROR: io-timeout ;

M: io-timeout summary drop "I/O operation timed out" ;

: wait-for-port ( port event -- )
    [
        >r handle>> r> wait-for-fd
        [ io-timeout ] when
    ] curry with-timeout ;

! Some general stuff
: file-mode OCT: 0666 ;

: (io-error) ( -- * ) err_no strerror throw ;

: check-errno ( -- )
    err_no dup zero? [ drop ] [ strerror throw ] if ;

: check-null ( n -- ) zero? [ (io-error) ] when ;

: io-error ( n -- ) 0 < [ (io-error) ] when ;
 
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

M: fd refill
    fd>> over buffer>> [ buffer-end ] [ buffer-capacity ] bi read
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

M: fd drain
    fd>> over buffer>> [ buffer@ ] [ buffer-length ] bi write
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
    dup dup handle>> drain dup [ wait-for-port ] [ 2drop ] if ;

M: unix io-multiplex ( ms/f -- )
    mx get-global wait-for-events ;

M: unix (init-stdio) ( -- )
    0 <fd> <input-port>
    1 <fd> <output-port>
    2 <fd> <output-port> ;

! mx io-task for embedding an fd-based mx inside another mx
TUPLE: mx-port < port mx ;

: <mx-port> ( mx -- port )
    dup fd>> mx-port <port> swap >>mx ;

: multiplexer-error ( n -- )
    0 < [
        err_no [ EAGAIN = ] [ EINTR = ] bi or
        [ (io-error) ] unless
    ] when ;

: ?flag ( n mask symbol -- n )
    pick rot bitand 0 > [ , ] [ drop ] if ;
