! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel io sequences io.buffers io.timeouts generic
byte-vectors system io.encodings math.order io.backend
continuations classes byte-arrays namespaces splitting
grouping dlists assocs io.encodings.binary summary accessors
destructors combinators ;
IN: io.ports

SYMBOL: default-buffer-size
64 1024 * default-buffer-size set-global

TUPLE: port handle timeout disposed ;

M: port timeout timeout>> ;

M: port set-timeout (>>timeout) ;

: <port> ( handle class -- port )
    new swap >>handle ; inline

TUPLE: buffered-port < port { buffer buffer } ;

: <buffered-port> ( handle class -- port )
    <port>
        default-buffer-size get <buffer> >>buffer ; inline

TUPLE: input-port < buffered-port ;

M: input-port stream-element-type drop +byte+ ;

: <input-port> ( handle -- input-port )
    input-port <buffered-port> ;

HOOK: (wait-to-read) io-backend ( port -- )

: wait-to-read ( port -- eof? )
    dup buffer>> buffer-empty? [
        dup (wait-to-read) buffer>> buffer-empty?
    ] [ drop f ] if ; inline

M: input-port stream-read1
    dup check-disposed
    dup wait-to-read [ drop f ] [ buffer>> buffer-pop ] if ; inline

: read-step ( count port -- byte-array/f )
    dup wait-to-read [ 2drop f ] [ buffer>> buffer-read ] if ;

M: input-port stream-read-partial ( max stream -- byte-array/f )
    dup check-disposed
    [ 0 max >integer ] dip read-step ;

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
    [ 0 max >fixnum ] dip
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
        [ over push-all ] dip dup [
            [ 3drop ] dip
        ] [
            drop read-until-loop
        ] if
    ] [
        [ 2drop 2drop ] dip
    ] if ;

M: input-port stream-read-until ( seps port -- str/f sep/f )
    2dup read-until-step dup [ [ 2drop ] 2dip ] [
        over [
            drop
            BV{ } like [ read-until-loop ] keep B{ } like swap
        ] [ [ 2drop ] 2dip ] if
    ] if ;

TUPLE: output-port < buffered-port ;

: <output-port> ( handle -- output-port )
    output-port <buffered-port> ;

: wait-to-write ( len port -- )
    [ nip ] [ buffer>> buffer-capacity <= ] 2bi
    [ drop ] [ stream-flush ] if ; inline

M: output-port stream-element-type stream>> stream-element-type ;

M: output-port stream-write1
    dup check-disposed
    1 over wait-to-write
    buffer>> byte>buffer ; inline

M: output-port stream-write
    dup check-disposed
    over length over buffer>> size>> > [
        [ buffer>> size>> <groups> ]
        [ [ stream-write ] curry ] bi
        each
    ] [
        [ [ length ] dip wait-to-write ]
        [ buffer>> >buffer ] 2bi
    ] if ;

HOOK: (wait-to-write) io-backend ( port -- )

HOOK: seek-handle os ( n seek-type handle -- )

M: input-port stream-seek ( n seek-type stream -- )
    [ check-disposed ]
    [ buffer>> 0 swap buffer-reset ]
    [ handle>> seek-handle ] tri ;

M: output-port stream-seek ( n seek-type stream -- )
    [ check-disposed ]
    [ stream-flush ]
    [ handle>> seek-handle ] tri ;

GENERIC: shutdown ( handle -- )

M: object shutdown drop ;

: port-flush ( port -- )
    dup buffer>> buffer-empty?
    [ drop ] [ dup (wait-to-write) port-flush ] if ;

M: output-port stream-flush ( port -- )
    [ check-disposed ] [ port-flush ] bi ;

M: output-port dispose*
    [
        {
            [ handle>> &dispose drop ]
            [ buffer>> &dispose drop ]
            [ port-flush ]
            [ handle>> shutdown ]
        } cleave
    ] with-destructors ;

M: buffered-port dispose*
    [ call-next-method ] [ buffer>> dispose ] bi ;

M: port cancel-operation handle>> cancel-operation ;

M: port dispose*
    [
        [ handle>> &dispose drop ]
        [ handle>> shutdown ]
        bi
    ] with-destructors ;

GENERIC: underlying-port ( stream -- port )

M: port underlying-port ;

M: encoder underlying-port stream>> underlying-port ;

M: decoder underlying-port stream>> underlying-port ;

GENERIC: underlying-handle ( stream -- handle )

M: object underlying-handle underlying-port handle>> ;

! Fast-path optimization
USING: hints strings io.encodings.utf8 io.encodings.ascii
io.encodings.private ;

HINTS: decoder-read-until { string input-port utf8 } { string input-port ascii } ;

HINTS: decoder-readln { input-port utf8 } { input-port ascii } ;

HINTS: encoder-write { object output-port utf8 } { object output-port ascii } ;
