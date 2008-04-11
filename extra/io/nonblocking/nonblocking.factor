! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
IN: io.nonblocking
USING: math kernel io sequences io.buffers io.timeouts generic
byte-vectors system io.streams.duplex io.encodings
io.backend continuations debugger classes byte-arrays namespaces
splitting dlists assocs io.encodings.binary ;

SYMBOL: default-buffer-size
64 1024 * default-buffer-size set-global

! Common delegate of native stream readers and writers
TUPLE: port
handle
buffer
error
timeout
type eof ;

M: port timeout port-timeout ;

M: port set-timeout set-port-timeout ;

SYMBOL: closed

PREDICATE: input-port < port port-type input-port eq? ;
PREDICATE: output-port < port port-type output-port eq? ;

GENERIC: init-handle ( handle -- )
GENERIC: close-handle ( handle -- )

: <port> ( handle type -- port )
    port construct-empty
        swap >>type
        swap dup init-handle >>handle ;

: <buffered-port> ( handle type -- port )
    <port>
        default-buffer-size get <buffer> >>buffer ;

: <reader> ( handle -- input-port )
    input-port <buffered-port> ;

: <writer> ( handle -- output-port )
    output-port <buffered-port> ;

: <reader&writer> ( read-handle write-handle -- input-port output-port )
    swap <reader> [ swap <writer> ] [ ] [ dispose drop ] cleanup ;

: pending-error ( port -- )
    [ f ] change-error drop [ throw ] when* ;

HOOK: cancel-io io-backend ( port -- )

M: object cancel-io drop ;

M: port timed-out cancel-io ;

GENERIC: (wait-to-read) ( port -- )

: wait-to-read ( count port -- )
    tuck buffer>> buffer-length > [ (wait-to-read) ] [ drop ] if ;

: wait-to-read1 ( port -- )
    1 swap wait-to-read ;

: unless-eof ( port quot -- value )
    >r dup buffer>> buffer-empty? over eof>> and
    [ f >>eof drop f ] r> if ; inline

M: input-port stream-read1
    dup wait-to-read1 [ buffer>> buffer-pop ] unless-eof ;

: read-step ( count port -- byte-array/f )
    [ wait-to-read ] 2keep
    [ dupd buffer>> buffer-read ] unless-eof nip ;

: read-loop ( count port accum -- )
    pick over length - dup 0 > [
        pick read-step dup [
            over push-all read-loop
        ] [
            2drop 2drop
        ] if
    ] [
        2drop 2drop
    ] if ;

M: input-port stream-read
    >r 0 max >fixnum r>
    2dup read-step dup [
        pick over length > [
            pick <byte-vector>
            [ push-all ] keep
            [ read-loop ] keep
            B{ } like
        ] [ 2nip ] if
    ] [ 2nip ] if ;

M: input-port stream-read-partial ( max stream -- byte-array/f )
    >r 0 max >fixnum r> read-step ;

: can-write? ( len buffer -- ? )
    [ buffer-fill + ] keep buffer-capacity <= ;

: wait-to-write ( len port -- )
    tuck buffer>> can-write? [ drop ] [ stream-flush ] if ;

M: output-port stream-write1
    1 over wait-to-write
    buffer>> byte>buffer ;

M: output-port stream-write
    over length over buffer>> buffer-size > [
        [ buffer>> buffer-size <groups> ]
        [ [ stream-write ] curry ] bi
        each
    ] [
        [ >r length r> wait-to-write ]
        [ buffer>> >buffer ] 2bi
    ] if ;

GENERIC: port-flush ( port -- )

M: output-port stream-flush ( port -- )
    [ port-flush ] [ pending-error ] bi ;

: close-port ( port type -- )
    output-port eq? [ dup port-flush ] when
    dup cancel-io
    dup handle>> close-handle
    [ [ buffer-free ] when* f ] change-buffer drop ;

M: port dispose
    dup type>> closed eq?
    [ drop ]
    [ [ closed ] change-type swap close-port ]
    if ;

TUPLE: server-port addr client client-addr encoding ;

: <server-port> ( handle addr encoding -- server )
    rot server-port <port>
    { set-server-port-addr set-server-port-encoding set-delegate }
    server-port construct ;

: check-server-port ( port -- )
    port-type server-port assert= ;

TUPLE: datagram-port addr packet packet-addr ;

: <datagram-port> ( handle addr -- datagram )
    >r datagram-port <port> r>
    { set-delegate set-datagram-port-addr }
    datagram-port construct ;

: check-datagram-port ( port -- )
    port-type datagram-port assert= ;

: check-datagram-send ( packet addrspec port -- )
    dup check-datagram-port
    datagram-port-addr [ class ] bi@ assert=
    class byte-array assert= ;
