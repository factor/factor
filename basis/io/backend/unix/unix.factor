! Copyright (C) 2004, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax classes
classes.struct combinators destructors destructors.private fry
io.backend io.backend.unix.multiplexers io.buffers io.files
io.ports io.timeouts kernel kernel.private libc locals make math
namespaces sequences summary system threads unix unix.ffi
unix.signals unix.stat unix.types ;
QUALIFIED: io
IN: io.backend.unix

CONSTANT: file-mode 0o0666

GENERIC: handle-fd ( handle -- fd )

TUPLE: fd < disposable fd ;

: init-fd ( fd -- fd )
    [
        |dispose
        dup fd>> F_SETFL O_NONBLOCK [ fcntl ] unix-system-call drop
        dup fd>> F_SETFD FD_CLOEXEC [ fcntl ] unix-system-call drop
    ] with-destructors ;

: <fd> ( n -- fd )
    fd new-disposable swap >>fd ;

M: fd dispose
    [
        {
            [ cancel-operation ]
            [ t >>disposed drop ]
            [ unregister-disposable ]
            [ fd>> close-file ]
        } cleave
    ] unless-disposed ;

M: fd handle-fd check-disposed fd>> ;

M: fd cancel-operation
    [
        fd>>
        mx get-global
        [ remove-input-callbacks [ t swap resume-with ] each ]
        [ remove-output-callbacks [ t swap resume-with ] each ]
        2bi
    ] unless-disposed ;

M: unix tell-handle
    fd>> 0 SEEK_CUR [ lseek ] unix-system-call [ io-error ] [ ] bi ;

M: unix seek-handle
    swap {
        { io:seek-absolute [ SEEK_SET ] }
        { io:seek-relative [ SEEK_CUR ] }
        { io:seek-end [ SEEK_END ] }
        [ io:bad-seek-type ]
    } case
    [ fd>> swap ] dip [ lseek ] unix-system-call drop ;

M: unix can-seek-handle?
    fd>> 0 SEEK_CUR lseek -1 = not ;

M: unix handle-length
    fd>> \ stat new [ fstat -1 = not ] keep
    swap [ st_size>> ] [ drop f ] if ;

ERROR: io-timeout ;

M: io-timeout summary drop "I/O operation timed out" ;

M: unix wait-for-fd
    dup +retry+ eq? [ 2drop ] [
        [ [ self ] dip handle-fd mx get-global ] dip {
            { +input+ [ add-input-callback ] }
            { +output+ [ add-output-callback ] }
        } case
        "I/O" suspend [ io-timeout ] when
    ] if ;

! Some general stuff

M: fd refill
    [ buffered-port check-instance buffer>> ] [ fd>> ] bi*
    over [ buffer-end ] [ buffer-capacity ] bi read
    { fixnum } declare dup 0 >= [
        swap buffer+ f
    ] [
        errno {
            { EINTR [ 2drop +retry+ ] }
            { EAGAIN [ 2drop +input+ ] }
            [ (throw-errno) ]
        } case
    ] if ;

M: unix (wait-to-read)
    dup
    dup handle>> check-disposed refill dup
    [ dupd wait-for-port (wait-to-read) ] [ 2drop ] if ;

! Writers
M: fd drain
    [ buffered-port check-instance buffer>> ] [ fd>> ] bi*
    over [ buffer@ ] [ buffer-length ] bi write
    { fixnum } declare dup 0 >= [
        over buffer-consume
        buffer-empty? f +output+ ?
    ] [
        errno {
            { EINTR [ 2drop +retry+ ] }
            { EAGAIN [ 2drop +output+ ] }
            { ENOBUFS [ 2drop +output+ ] }
            [ (throw-errno) ]
        } case
    ] if ;

M: unix (wait-to-write)
    dup
    dup handle>> check-disposed drain
    [ wait-for-port ] [ drop ] if* ;

M: unix io-multiplex
    mx get-global wait-for-events ;

! On Unix, you're not supposed to set stdin to non-blocking
! because the fd might be shared with another process (either
! parent or child). So what we do is have the VM start a thread
! which pumps data from the real stdin to a pipe. We set the
! pipe to non-blocking, and read from it instead of the real
! stdin. Very crufty, but it will suffice until we get native
! threading support at the language level.
TUPLE: stdin < disposable control size data ;

M: stdin dispose*
    [
        [ control>> &dispose drop ]
        [ size>> &dispose drop ]
        [ data>> &dispose drop ]
        tri
    ] with-destructors ;

: wait-for-stdin ( stdin -- size )
    [ control>> CHAR: X over io:stream-write1 io:stream-flush ]
    [ size>> ssize_t swap stream-read-c-ptr ]
    bi ;

:: refill-stdin ( buffer stdin size -- )
    stdin data>> handle-fd buffer buffer-end size read
    dup 0 < [
        drop
        errno EINTR = [
            buffer stdin size refill-stdin
        ] [
            throw-errno
        ] if
    ] [
        size = [ "Error reading stdin pipe" throw ] unless
        size buffer buffer+
    ] if ;

M: stdin refill
    '[
        buffer>> _ dup wait-for-stdin refill-stdin f
    ] with-timeout ;

M: stdin cancel-operation
    [ size>> ] [ control>> ] bi [ cancel-operation ] bi@ ;

: control-write-fd ( -- fd ) &: control_write uint deref ;

: size-read-fd ( -- fd ) &: size_read uint deref ;

: data-read-fd ( -- fd ) &: stdin_read uint deref ;

: <stdin> ( -- stdin )
    stdin new-disposable
        control-write-fd <fd> <output-port> >>control
        size-read-fd <fd> init-fd <input-port> >>size
        data-read-fd <fd> >>data ;

: signal-pipe-fd ( -- n )
    OBJ-SIGNAL-PIPE special-object ; inline

: signal-pipe-loop ( port -- )
    '[
        int heap-size _ io:stream-read
        dup [ int deref dispatch-signal-hook get-global call( x -- ) ] when*
    ] loop ;

: start-signal-pipe-thread ( -- )
    signal-pipe-fd [
        <fd> init-fd <input-port>
        '[ _ signal-pipe-loop ] "Signals" spawn drop
    ] when* ;

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
        [ drop 0 ] [ throw-errno ] if
    ] when ;

:: ?flag ( n mask symbol -- n )
    n mask bitand 0 > [ symbol , ] when n ;
