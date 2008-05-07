! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel io sequences io.buffers io.timeouts generic
byte-vectors system io.encodings math.order io.backend
continuations debugger classes byte-arrays namespaces splitting
dlists assocs io.encodings.binary inspector accessors ;
IN: io.nonblocking

SYMBOL: default-buffer-size
64 1024 * default-buffer-size set-global

TUPLE: port handle buffer error timeout closed eof ;

M: port timeout timeout>> ;

M: port set-timeout (>>timeout) ;

GENERIC: init-handle ( handle -- )

GENERIC: close-handle ( handle -- )

: <port> ( handle class -- port )
    new
        swap dup init-handle >>handle ; inline

: <buffered-port> ( handle class -- port )
    <port>
        default-buffer-size get <buffer> >>buffer ; inline

TUPLE: input-port < port ;

: <reader> ( handle -- input-port )
    input-port <buffered-port> ;

TUPLE: output-port < port ;

: <writer> ( handle -- output-port )
    output-port <buffered-port> ;

: <reader&writer> ( read-handle write-handle -- input-port output-port )
    swap <reader> [ swap <writer> ] [ ] [ dispose drop ] cleanup ;

: pending-error ( port -- )
    [ f ] change-error drop [ throw ] when* ;

ERROR: port-closed-error port ;

M: port-closed-error summary
    drop "Port has been closed" ;

: check-closed ( port -- port )
    dup closed>> [ port-closed-error ] when ;

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
    check-closed
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
    check-closed
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
    check-closed
    >r 0 max >fixnum r> read-step ;

: can-write? ( len buffer -- ? )
    [ buffer-fill + ] keep buffer-capacity <= ;

: wait-to-write ( len port -- )
    tuck buffer>> can-write? [ drop ] [ stream-flush ] if ;

M: output-port stream-write1
    check-closed
    1 over wait-to-write
    buffer>> byte>buffer ;

M: output-port stream-write
    check-closed
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
    check-closed
    [ port-flush ] [ pending-error ] bi ;

GENERIC: close-port ( port -- )

M: output-port close-port
    [ port-flush ] [ call-next-method ] bi ;

M: port close-port
    dup cancel-io
    dup handle>> close-handle
    [ [ buffer-free ] when* f ] change-buffer drop ;

M: port dispose
    dup closed>> [ drop ] [ t >>closed close-port ] if ;

TUPLE: server-port < port addr client client-addr encoding ;

: <server-port> ( handle addr encoding -- server )
    rot server-port <port>
        swap >>encoding
        swap >>addr ;

: check-server-port ( port -- port )
    dup server-port? [ "Not a server port" throw ] unless ; inline

TUPLE: datagram-port < port addr packet packet-addr ;

: <datagram-port> ( handle addr -- datagram )
    swap datagram-port <port>
        swap >>addr ;

: check-datagram-port ( port -- port )
    check-closed
    dup datagram-port? [ "Not a datagram port" throw ] unless ; inline

: check-datagram-send ( packet addrspec port -- packet addrspec port )
    check-datagram-port
    2dup addr>> [ class ] bi@ assert=
    pick class byte-array assert= ;
