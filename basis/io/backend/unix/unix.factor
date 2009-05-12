! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax generic assocs kernel
kernel.private math io.ports sequences strings sbufs threads
unix vectors io.buffers io.backend io.encodings math.parser
continuations system libc namespaces make io.timeouts
io.encodings.utf8 destructors accessors summary combinators
locals unix.time fry io.backend.unix.multiplexers ;
QUALIFIED: io
IN: io.backend.unix

GENERIC: handle-fd ( handle -- fd )

TUPLE: fd fd disposed ;

: init-fd ( fd -- fd )
    [
        |dispose
        dup fd>> F_SETFL O_NONBLOCK fcntl io-error
        dup fd>> F_SETFD FD_CLOEXEC fcntl io-error
    ] with-destructors ;

: <fd> ( n -- fd )
    #! We drop the error code rather than calling io-error,
    #! since on OS X 10.3, this operation fails from init-io
    #! when running the Factor.app (presumably because fd 0 and
    #! 1 are closed).
    f fd boa ;

M: fd dispose
    dup disposed>> [ drop ] [
        [ cancel-operation ]
        [ t >>disposed drop ]
        [ fd>> close-file ]
        tri
    ] if ;

M: fd handle-fd dup check-disposed fd>> ;

M: fd cancel-operation ( fd -- )
    dup disposed>> [ drop ] [
        fd>>
        mx get-global
        [ remove-input-callbacks [ t swap resume-with ] each ]
        [ remove-output-callbacks [ t swap resume-with ] each ]
        2bi
    ] if ;

M: unix seek-handle ( n seek-type handle -- )
    swap {
        { io:seek-absolute [ SEEK_SET ] }
        { io:seek-relative [ SEEK_CUR ] }
        { io:seek-end [ SEEK_END ] }
        [ io:bad-seek-type ]
    } case
    [ fd>> swap ] dip lseek io-error ;

SYMBOL: +retry+ ! just try the operation again without blocking
SYMBOL: +input+
SYMBOL: +output+

ERROR: io-timeout ;

M: io-timeout summary drop "I/O operation timed out" ;

: wait-for-fd ( handle event -- )
    dup +retry+ eq? [ 2drop ] [
        '[
            swap handle-fd mx get-global _ {
                { +input+ [ add-input-callback ] }
                { +output+ [ add-output-callback ] }
            } case
        ] "I/O" suspend nip [ io-timeout ] when
    ] if ;

: wait-for-port ( port event -- )
    '[ handle>> _ wait-for-fd ] with-timeout ;

! Some general stuff
CONSTANT: file-mode OCT: 0666
 
! Readers
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
        { [ dup 0 >= ] [ swap buffer>> n>buffer f ] }
        { [ errno EINTR = ] [ 2drop +retry+ ] }
        { [ errno EAGAIN = ] [ 2drop +input+ ] }
        [ (io-error) ]
    } cond ;

M: unix (wait-to-read) ( port -- )
    dup
    dup handle>> dup check-disposed refill dup
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
        { [ errno EINTR = ] [ 2drop +retry+ ] }
        { [ errno EAGAIN = ] [ 2drop +output+ ] }
        [ (io-error) ]
    } cond ;

M: unix (wait-to-write) ( port -- )
    dup
    dup handle>> dup check-disposed drain
    dup [ wait-for-port ] [ 2drop ] if ;

M: unix io-multiplex ( ms/f -- )
    mx get-global wait-for-events ;

! On Unix, you're not supposed to set stdin to non-blocking
! because the fd might be shared with another process (either
! parent or child). So what we do is have the VM start a thread
! which pumps data from the real stdin to a pipe. We set the
! pipe to non-blocking, and read from it instead of the real
! stdin. Very crufty, but it will suffice until we get native
! threading support at the language level.
TUPLE: stdin control size data disposed ;

M: stdin dispose*
    [
        [ control>> &dispose drop ]
        [ size>> &dispose drop ]
        [ data>> &dispose drop ]
        tri
    ] with-destructors ;

: wait-for-stdin ( stdin -- n )
    [ control>> CHAR: X over io:stream-write1 io:stream-flush ]
    [ size>> "ssize_t" heap-size swap io:stream-read *int ]
    bi ;

:: refill-stdin ( buffer stdin size -- )
    stdin data>> handle-fd buffer buffer-end size read
    dup 0 < [
        drop
        errno EINTR = [ buffer stdin size refill-stdin ] [ (io-error) ] if
    ] [
        size = [ "Error reading stdin pipe" throw ] unless
        size buffer n>buffer
    ] if ;

M: stdin refill
    [ buffer>> ] [ dup wait-for-stdin ] bi* refill-stdin f ;

: control-write-fd ( -- fd ) &: control_write *uint ;

: size-read-fd ( -- fd ) &: size_read *uint ;

: data-read-fd ( -- fd ) &: stdin_read *uint ;

: <stdin> ( -- stdin )
    stdin new
        control-write-fd <fd> <output-port> >>control
        size-read-fd <fd> init-fd <input-port> >>size
        data-read-fd <fd> >>data ;

M: unix init-stdio
    <stdin> <input-port>
    1 <fd> <output-port>
    2 <fd> <output-port>
    set-stdio ;

! mx io-task for embedding an fd-based mx inside another mx
TUPLE: mx-port < port mx ;

: <mx-port> ( mx -- port )
    dup fd>> mx-port <port> swap >>mx ;

: multiplexer-error ( n -- n )
    dup 0 < [
        errno [ EAGAIN = ] [ EINTR = ] bi or
        [ drop 0 ] [ (io-error) ] if
    ] when ;

: ?flag ( n mask symbol -- n )
    pick rot bitand 0 > [ , ] [ drop ] if ;
