! Copyright (C) 2005, 2007 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
IN: io.nonblocking
USING: math kernel io sequences io.buffers generic sbufs
system io.streams.lines io.streams.plain io.streams.duplex
continuations debugger classes byte-arrays namespaces ;

SYMBOL: default-buffer-size
64 1024 * default-buffer-size set-global

! Common delegate of native stream readers and writers
TUPLE: port handle error timeout cutoff type eof? ;

SYMBOL: input
SYMBOL: output
SYMBOL: closed

PREDICATE: port input-port port-type input eq? ;
PREDICATE: port output-port port-type output eq? ;

GENERIC: init-handle ( handle -- )
GENERIC: close-handle ( handle -- )

: <port> ( handle buffer -- port )
    over init-handle
    0 0 {
        set-port-handle
        set-delegate
        set-port-timeout
        set-port-cutoff
    } port construct ;

: <buffered-port> ( handle -- port )
    default-buffer-size get <buffer> <port> ;

: <reader> ( handle -- stream )
    <buffered-port> input over set-port-type <line-reader> ;

: <writer> ( handle -- stream )
    <buffered-port> output over set-port-type <plain-writer> ;

: handle>duplex-stream ( in-handle out-handle -- stream )
    <writer>
    [ >r <reader> r> <duplex-stream> ]
    [ ] [ stream-close ]
    cleanup ;

: touch-port ( port -- )
    dup port-timeout dup zero?
    [ 2drop ] [ millis + swap set-port-cutoff ] if ;

: timeout? ( port -- ? )
    port-cutoff dup zero? not swap millis < and ;

: pending-error ( port -- )
    dup port-error f rot set-port-error [ throw ] when* ;

M: port set-timeout
    [ set-port-timeout ] keep touch-port ;

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

: read-step ( count port -- string/f )
    [ wait-to-read ] 2keep
    [ dupd buffer> ] unless-eof nip ;

: read-loop ( count port sbuf -- )
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
            pick <sbuf>
            [ push-all ] keep
            [ read-loop ] keep
            "" like
        ] [
            2nip
        ] if
    ] [
        2nip
    ] if ;

: read-until-step ( separators port -- string/f separator/f )
    dup wait-to-read1
    dup port-eof? [
        f swap set-port-eof? drop f f
    ] [
        buffer-until
    ] if ;

: read-until-loop ( seps port sbuf -- separator/f )
    pick pick read-until-step over [
        >r over push-all r> dup [
            >r 3drop r>
        ] [
            drop read-until-loop
        ] if
    ] [
        >r 2drop 2drop r>
    ] if ;

M: input-port stream-read-until ( seps port -- str/f sep/f )
    2dup read-until-step dup [
        >r 2nip r>
    ] [
        over [
            drop >sbuf [ read-until-loop ] keep "" like swap
        ] [
            >r 2nip r>
        ] if
    ] if ;

M: input-port stream-read-partial ( max stream -- string/f )
    >r 0 max >fixnum r> read-step ;

: can-write? ( len writer -- ? )
    dup buffer-empty? [
        2drop t
    ] [
        [ buffer-fill + ] keep buffer-capacity <=
    ] if ;

: wait-to-write ( len port -- )
    tuck can-write? [ drop ] [ stream-flush ] if ;

M: output-port stream-write1
    1 over wait-to-write ch>buffer ;

M: output-port stream-write
    over length over wait-to-write >buffer ;

GENERIC: port-flush ( port -- )

M: output-port stream-flush ( port -- )
    dup port-flush pending-error ;

M: port stream-close
    dup port-type closed eq? [
        dup port-type >r closed over set-port-type r>
        output eq? [ dup port-flush ] when
        dup port-handle close-handle
        dup delegate [ buffer-free ] when*
        f over set-delegate
    ] unless drop ;

TUPLE: server-port addr client ;

: <server-port> ( port addr -- server )
    server-port pick set-port-type
    { set-delegate set-server-port-addr }
    server-port construct ;

: check-server-port ( port -- )
    port-type server-port assert= ;

TUPLE: datagram-port addr packet packet-addr ;

: <datagram-port> ( port addr -- datagram )
    datagram-port pick set-port-type
    { set-delegate set-datagram-port-addr }
    datagram-port construct ;

: check-datagram-port ( port -- )
    port-type datagram-port assert= ;

: check-datagram-send ( packet addrspec port -- )
    dup check-datagram-port
    datagram-port-addr [ class ] 2apply assert=
    class byte-array assert= ;
