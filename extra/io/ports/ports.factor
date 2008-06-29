! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel io sequences io.buffers io.timeouts generic
byte-vectors system io.encodings math.order io.backend
continuations debugger classes byte-arrays namespaces splitting
grouping dlists assocs io.encodings.binary inspector accessors
destructors ;
IN: io.ports

SYMBOL: default-buffer-size
64 1024 * default-buffer-size set-global

TUPLE: port handle timeout disposed ;

M: port timeout timeout>> ;

M: port set-timeout (>>timeout) ;

: <port> ( handle class -- port )
    new swap >>handle ; inline

TUPLE: buffered-port < port buffer ;

: <buffered-port> ( handle class -- port )
    <port>
        default-buffer-size get <buffer> >>buffer ; inline

TUPLE: input-port < buffered-port ;

: <input-port> ( handle -- input-port )
    input-port <buffered-port> ;

HOOK: (wait-to-read) io-backend ( port -- )

: wait-to-read ( port -- eof? )
    dup buffer>> buffer-empty? [
        dup (wait-to-read) buffer>> buffer-empty?
    ] [ drop f ] if ;

M: input-port stream-read1
    dup check-disposed
    dup wait-to-read [ drop f ] [ buffer>> buffer-pop ] if ;

: read-step ( count port -- byte-array/f )
    dup wait-to-read [ 2drop f ] [ buffer>> buffer-read ] if ;

M: input-port stream-read-partial ( max stream -- byte-array/f )
    dup check-disposed
    >r 0 max >integer r> read-step ;

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
    dup check-disposed
    >r 0 max >fixnum r>
    2dup read-step dup [
        pick over length > [
            pick <byte-vector>
            [ push-all ] keep
            [ read-loop ] keep
            B{ } like
        ] [ 2nip ] if
    ] [ 2nip ] if ;

: read-until-step ( separators port -- string/f separator/f )
    dup wait-to-read [ 2drop f f ] [ buffer>> buffer-until ] if ;

: read-until-loop ( seps port buf -- separator/f )
    2over read-until-step over [
        >r over push-all r> dup [
            >r 3drop r>
        ] [
            drop read-until-loop
        ] if
    ] [
        >r 2drop 2drop r>
    ] if ;

M: input-port stream-read-until ( seps port -- str/f sep/f )
    2dup read-until-step dup [ >r 2nip r> ] [
        over [
            drop
            BV{ } like [ read-until-loop ] keep B{ } like swap
        ] [ >r 2nip r> ] if
    ] if ;

TUPLE: output-port < buffered-port ;

: <output-port> ( handle -- output-port )
    output-port <buffered-port> ;

: wait-to-write ( len port -- )
    tuck buffer>> buffer-capacity <=
    [ drop ] [ stream-flush ] if ;

M: output-port stream-write1
    dup check-disposed
    1 over wait-to-write
    buffer>> byte>buffer ;

M: output-port stream-write
    dup check-disposed
    over length over buffer>> buffer-size > [
        [ buffer>> size>> <groups> ]
        [ [ stream-write ] curry ] bi
        each
    ] [
        [ >r length r> wait-to-write ]
        [ buffer>> >buffer ] 2bi
    ] if ;

HOOK: (wait-to-write) io-backend ( port -- )

GENERIC: shutdown ( handle -- )

M: object shutdown drop ;

: port-flush ( port -- )
    dup buffer>> buffer-empty?
    [ drop ] [ dup (wait-to-write) port-flush ] if ;

M: output-port stream-flush ( port -- )
    [ check-disposed ] [ port-flush ] bi ;

M: output-port dispose*
    [
        [ handle>> &dispose drop ]
        [ port-flush ]
        [ handle>> shutdown ]
        tri
    ] with-destructors ;

M: buffered-port dispose*
    [ call-next-method ]
    [ [ [ dispose ] when* f ] change-buffer drop ]
    bi ;

M: port cancel-operation handle>> cancel-operation ;

M: port dispose*
    [
        [ handle>> &dispose drop ]
        [ handle>> shutdown ]
        bi
    ] with-destructors ;
