! Copyright (C) 2005, 2010 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel io sequences io.buffers io.timeouts generic
byte-vectors system io.encodings math.order io.backend
continuations classes byte-arrays namespaces splitting grouping
dlists alien alien.c-types assocs io.encodings.binary summary
accessors destructors combinators fry specialized-arrays
locals ;
SPECIALIZED-ARRAY: uchar
IN: io.ports

SYMBOL: default-buffer-size
64 1024 * default-buffer-size set-global

TUPLE: port < disposable handle timeout ;

M: port timeout timeout>> ;

M: port set-timeout timeout<< ;

: <port> ( handle class -- port )
    new-disposable swap >>handle ; inline

TUPLE: buffered-port < port { buffer buffer } ;

: <buffered-port> ( handle class -- port )
    <port>
        default-buffer-size get <buffer> >>buffer ; inline

TUPLE: input-port < buffered-port ;

M: input-port stream-element-type drop +byte+ ; inline

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
    {
        { [ over 0 = ] [ 2drop f ] }
        { [ dup wait-to-read ] [ 2drop f ] }
        [ buffer>> buffer-read ]
    } cond ;

: prepare-read ( count stream -- count stream )
    dup check-disposed [ 0 max >fixnum ] dip ; inline

M: input-port stream-read-partial ( max stream -- byte-array/f )
    prepare-read read-step ;

: read-loop ( count port accum -- )
    pick over length - dup 0 > [
        pick read-step dup [
            append! read-loop
        ] [
            2drop 2drop
        ] if
    ] [
        2drop 2drop
    ] if ;

M: input-port stream-read
    prepare-read
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
        [ append! ] dip dup [
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

M: output-port stream-element-type
    stream>> stream-element-type ; inline

M: output-port stream-write1
    dup check-disposed
    1 over wait-to-write
    buffer>> byte>buffer ; inline

: write-in-groups ( byte-array port -- )
    [ binary-object <direct-uchar-array> ] dip
    [ buffer>> size>> <sliced-groups> ] [ '[ _ stream-write ] ] bi
    each ;

M: output-port stream-write
    dup check-disposed
    2dup [ byte-length ] [ buffer>> size>> ] bi* > [
        write-in-groups
    ] [
        [ [ byte-length ] dip wait-to-write ]
        [ buffer>> >buffer ] 2bi
    ] if ;

HOOK: (wait-to-write) io-backend ( port -- )

: port-flush ( port -- )
    dup buffer>> buffer-empty?
    [ drop ] [ dup (wait-to-write) port-flush ] if ;

M: output-port stream-flush ( port -- )
    [ check-disposed ] [ port-flush ] bi ;

HOOK: tell-handle os ( handle -- n )

HOOK: seek-handle os ( n seek-type handle -- )

M: input-port stream-tell ( stream -- n )
    [ check-disposed ]
    [ [ handle>> tell-handle ] [ buffer>> buffer-length ] bi - ] bi ;

M: output-port stream-tell ( stream -- n )
    [ check-disposed ]
    [ [ handle>> tell-handle ] [ buffer>> buffer-length ] bi + ] bi ;

:: do-seek-relative ( n seek-type stream -- n seek-type stream )
    ! seek-relative needs special handling here, because of the
    ! buffer.
    seek-type seek-relative eq?
    [ n stream stream-tell + seek-absolute ] [ n seek-type ] if
    stream ;

M: input-port stream-seek ( n seek-type stream -- )
    do-seek-relative
    [ check-disposed ]
    [ buffer>> 0 swap buffer-reset ]
    [ handle>> seek-handle ] tri ;

M: output-port stream-seek ( n seek-type stream -- )
    do-seek-relative
    [ check-disposed ]
    [ stream-flush ]
    [ handle>> seek-handle ] tri ;

GENERIC: shutdown ( handle -- )

M: object shutdown drop ;

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
