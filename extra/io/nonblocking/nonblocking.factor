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
error
timeout
type eof? ;

M: port timeout port-timeout ;

M: port set-timeout set-port-timeout ;

SYMBOL: closed

PREDICATE: input-port < port port-type input-port eq? ;
PREDICATE: output-port < port port-type output-port eq? ;

GENERIC: init-handle ( handle -- )
GENERIC: close-handle ( handle -- )

: <port> ( handle buffer type -- port )
    pick init-handle {
        set-port-handle
        set-delegate
        set-port-type
    } port construct ;

: <buffered-port> ( handle type -- port )
    default-buffer-size get <buffer> swap <port> ;

: <reader> ( handle -- input-port )
    input-port <buffered-port> ;

: <writer> ( handle -- output-port )
    output-port <buffered-port> ;

: <reader&writer> ( read-handle write-handle -- input-port output-port )
    swap <reader> [ swap <writer> ] [ ] [ dispose drop ] cleanup ;

: pending-error ( port -- )
    dup port-error f rot set-port-error [ throw ] when* ;

HOOK: cancel-io io-backend ( port -- )

M: object cancel-io drop ;

M: port timed-out cancel-io ;

GENERIC: (wait-to-read) ( port -- )

: wait-to-read ( count port -- )
    tuck buffer-length > [ (wait-to-read) ] [ drop ] if ;

: wait-to-read1 ( port -- )
    1 swap wait-to-read ;

: unless-eof ( port quot -- value )
    >r dup buffer-empty? over port-eof? and
    [ f swap set-port-eof? f ] r> if ; inline

M: input-port stream-read1
    dup wait-to-read1 [ buffer-pop ] unless-eof ;

: read-step ( count port -- byte-array/f )
    [ wait-to-read ] 2keep
    [ dupd buffer> ] unless-eof nip ;

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
        ] [
            2nip
        ] if
    ] [
        2nip
    ] if ;

: read-until-step ( separators port -- byte-array/f separator/f )
    dup wait-to-read1
    dup port-eof? [
        f swap set-port-eof? drop f f
    ] [
        buffer-until
    ] if ;

: read-until-loop ( seps port accum -- separator/f )
    2over read-until-step over [
        >r over push-all r> dup [
            >r 3drop r>
        ] [
            drop read-until-loop
        ] if
    ] [
        >r 2drop 2drop r>
    ] if ;

M: input-port stream-read-until ( seps port -- byte-array/f sep/f )
    2dup read-until-step dup [
        >r 2nip r>
    ] [
        over [
            drop BV{ } like
            [ read-until-loop ] keep
            B{ } like swap
        ] [
            >r 2nip r>
        ] if
    ] if ;

M: input-port stream-read-partial ( max stream -- byte-array/f )
    >r 0 max >fixnum r> read-step ;

: can-write? ( len writer -- ? )
    [ buffer-fill + ] keep buffer-capacity <= ;

: wait-to-write ( len port -- )
    tuck can-write? [ drop ] [ stream-flush ] if ;

M: output-port stream-write1
    1 over wait-to-write byte>buffer ;

M: output-port stream-write
    over length over buffer-size > [
        [ buffer-size <groups> ] keep
        [ stream-write ] curry each
    ] [
        over length over wait-to-write >buffer
    ] if ;

GENERIC: port-flush ( port -- )

M: output-port stream-flush ( port -- )
    dup port-flush pending-error ;

: close-port ( port type -- )
    output-port eq? [ dup port-flush ] when
    dup cancel-io
    dup port-handle close-handle
    dup delegate [ buffer-free ] when*
    f swap set-delegate ;

M: port dispose
    dup port-type closed eq?
    [ drop ]
    [ dup port-type >r closed over set-port-type r> close-port ]
    if ;

TUPLE: server-port addr client client-addr encoding ;

: <server-port> ( handle addr encoding -- server )
    rot f server-port <port>
    { set-server-port-addr set-server-port-encoding set-delegate }
    server-port construct ;

: check-server-port ( port -- )
    port-type server-port assert= ;

TUPLE: datagram-port addr packet packet-addr ;

: <datagram-port> ( handle addr -- datagram )
    >r f datagram-port <port> r>
    { set-delegate set-datagram-port-addr }
    datagram-port construct ;

: check-datagram-port ( port -- )
    port-type datagram-port assert= ;

: check-datagram-send ( packet addrspec port -- )
    dup check-datagram-port
    datagram-port-addr [ class ] 2apply assert=
    class byte-array assert= ;
