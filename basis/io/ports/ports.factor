! Copyright (C) 2005, 2010 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data assocs
byte-arrays byte-vectors classes combinators continuations
destructors dlists fry generic grouping hints io io.backend
io.buffers io.encodings io.encodings.ascii io.encodings.binary
io.encodings.private io.encodings.utf8 io.timeouts kernel libc
locals math math.order namespaces sequences specialized-arrays
specialized-arrays.instances.alien.c-types.uchar splitting
strings summary system io.files kernel.private ;
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
INSTANCE: input-port input-stream
INSTANCE: input-port file-reader

: <input-port> ( handle -- input-port )
    input-port <buffered-port> ; inline

HOOK: (wait-to-read) io-backend ( port -- )

: wait-to-read ( port -- eof? )
    dup buffer>> buffer-empty? [
        dup (wait-to-read) buffer>> buffer-empty?
    ] [ drop f ] if ; inline

M: input-port stream-read1
    dup check-disposed
    dup wait-to-read [ drop f ] [ buffer>> buffer-pop ] if ; inline

: read-step ( count port -- count ptr/f )
    {
        { [ over 0 = ] [ 2drop 0 f ] }
        { [ dup wait-to-read ] [ 2drop 0 f ] }
        [ buffer>> buffer-read-unsafe ]
    } cond
    { fixnum c-ptr } declare ; inline

: prepare-read ( count stream -- count stream )
    dup check-disposed [ 0 max >fixnum ] dip ; inline

M: input-port stream-read-partial-unsafe ( n dst port -- count )
    [ swap ] dip prepare-read read-step
    [ swap [ memcpy ] keep ] [ 2drop 0 ] if* ;

:: read-loop ( n-remaining n-read port dst -- n-total )
    n-remaining 0 > [
        n-remaining port read-step :> ( n-buffered ptr )
        ptr [
            dst ptr n-buffered memcpy
            n-remaining n-buffered - :> n-remaining'
            n-read n-buffered + :> n-read'
            n-buffered dst <displaced-alien> :> dst'
            n-remaining' n-read' port dst' read-loop
        ] [ n-read ] if
    ] [ n-read ] if ; inline recursive

M:: input-port stream-read-unsafe ( n dst port -- count )
    n port prepare-read :> ( n' port' )
    n' port' read-step :> ( n-buffered ptr )
    ptr [
        dst ptr n-buffered memcpy
        n-buffered n' < [
            n-buffered dst <displaced-alien> :> dst'
            n' n-buffered - n-buffered port dst' read-loop
        ] [
            n-buffered
        ] if
    ] [ 0 ] if ;

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
        [ 4drop ] dip
    ] if ;

M: input-port stream-read-until ( seps port -- str/f sep/f )
    2dup read-until-step dup [ [ 2drop ] 2dip ] [
        over [
            drop
            BV{ } like [ read-until-loop ] keep B{ } like swap
        ] [ [ 2drop ] 2dip ] if
    ] if ;

TUPLE: output-port < buffered-port ;
INSTANCE: output-port output-stream
INSTANCE: output-port file-writer

: <output-port> ( handle -- output-port )
    output-port <buffered-port> ;

: wait-to-write ( len port -- )
    [ nip ] [ buffer>> buffer-capacity <= ] 2bi
    [ drop ] [ stream-flush ] if ; inline

M: output-port stream-write1
    dup check-disposed
    1 over wait-to-write
    buffer>> byte>buffer ; inline

: write-in-groups ( byte-array port -- )
    [ binary-object uchar <c-direct-array> ] dip
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

M: output-port stream-flush
    [ check-disposed ] [ port-flush ] bi ;

HOOK: tell-handle os ( handle -- n )

HOOK: seek-handle os ( n seek-type handle -- )

HOOK: can-seek-handle? os ( handle -- ? )
HOOK: handle-length os ( handle -- n/f )

M: input-port stream-tell
    [ check-disposed ]
    [ [ handle>> tell-handle ] [ buffer>> buffer-length ] bi - ] bi ;

M: output-port stream-tell
    [ check-disposed ]
    [ [ handle>> tell-handle ] [ buffer>> buffer-length ] bi + ] bi ;

:: do-seek-relative ( n seek-type stream -- n seek-type stream )
    ! seek-relative needs special handling here, because of the
    ! buffer.
    seek-type seek-relative eq?
    [ n stream stream-tell + seek-absolute ] [ n seek-type ] if
    stream ;

M: input-port stream-seek
    do-seek-relative
    [ check-disposed ]
    [ buffer>> 0 swap buffer-reset ]
    [ handle>> seek-handle ] tri ;

M: output-port stream-seek
    do-seek-relative
    [ check-disposed ]
    [ stream-flush ]
    [ handle>> seek-handle ] tri ;

M: buffered-port stream-seekable?
    handle>> can-seek-handle? ;

M: buffered-port stream-length
    handle>> handle-length ;

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
    [
        [ buffer>> &dispose drop ]
        [ call-next-method ] bi
    ] with-destructors ;

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

HINTS: (decode-until) { string input-port object } ;

HINTS: M\ input-port stream-read-partial-unsafe
    { fixnum byte-array input-port }
    { fixnum string input-port } ;

HINTS: M\ input-port stream-read-unsafe
    { fixnum byte-array input-port }
    { fixnum string input-port } ;

