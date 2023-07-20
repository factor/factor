! Copyright (C) 2005, 2010 Slava Pestov, Doug Coleman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien classes combinators destructors hints io
io.backend io.buffers io.encodings io.files io.timeouts kernel
kernel.private libc locals math math.order math.private
namespaces sequences strings system ;
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

: wait-for-port ( port event -- )
    '[ handle>> _ wait-for-fd ] with-timeout ;

HOOK: (wait-to-read) io-backend ( port -- )

: wait-to-read ( port -- eof? )
    dup buffer>> buffer-empty? [
        dup (wait-to-read) buffer>> buffer-empty?
    ] [ drop f ] if ; inline

M: input-port stream-read1
    check-disposed
    dup wait-to-read [ drop f ] [ buffer>> buffer-pop ] if ; inline

<PRIVATE

: read-step ( count port -- count ptr/f )
    {
        { [ over 0 = ] [ 2drop 0 f ] }
        { [ dup wait-to-read ] [ 2drop 0 f ] }
        [ buffer>> buffer-read-unsafe ]
    } cond
    { fixnum c-ptr } declare ; inline

: prepare-read ( count port -- count' port )
    [ integer>fixnum-strict 0 max ] dip check-disposed ; inline

:: read-loop ( dst n-remaining port n-read -- n-total )
    n-remaining port read-step :> ( n-buffered ptr )
    ptr [
        n-read dst <displaced-alien> ptr n-buffered memcpy
        n-remaining n-buffered fixnum-fast :> n-remaining'
        n-read n-buffered fixnum+fast :> n-read'
        dst n-remaining' port n-read' read-loop
    ] [ n-read ] if ; inline recursive

PRIVATE>

M: input-port stream-read-partial-unsafe
    [ c-ptr check-instance swap ] dip prepare-read read-step
    [ swap [ memcpy ] keep ] [ 2drop 0 ] if* ;

M: input-port stream-read-unsafe
    [ c-ptr check-instance swap ] dip prepare-read 0 read-loop ;

<PRIVATE

: read-until-step ( seps port -- byte-array/f sep/f )
    dup wait-to-read [ 2drop f f ] [
        buffer>> buffer-read-until
    ] if ; inline

: read-until-loop ( seps port accum -- sep/f )
    2over read-until-step over [
        [ append! ] dip dup [
            3nip
        ] [
            drop read-until-loop
        ] if
    ] [
        4nip
    ] if ; inline recursive

PRIVATE>

M: input-port stream-read-until
    2dup read-until-step dup [
        2nipd
    ] [
        over [
            drop
            BV{ } like [ read-until-loop ] keep B{ } like swap
        ] [
            2nipd
        ] if
    ] if ;

TUPLE: output-port < buffered-port ;
INSTANCE: output-port output-stream
INSTANCE: output-port file-writer

: <output-port> ( handle -- output-port )
    output-port <buffered-port> ;

HOOK: (wait-to-write) io-backend ( port -- )

<PRIVATE

: port-flush ( port -- )
    dup buffer>> buffer-empty?
    [ drop ] [ dup (wait-to-write) port-flush ] if ; inline recursive

PRIVATE>

M: output-port stream-flush
    check-disposed port-flush ;

: wait-to-write ( len port -- )
    [ nip ] [ buffer>> buffer-capacity <= ] 2bi
    [ drop ] [ port-flush ] if ; inline

M: output-port stream-write1
    check-disposed
    1 over wait-to-write
    buffer>> buffer-write1 ; inline

<PRIVATE

:: port-write ( src n-remaining port n-write  -- )
    port buffer>> :> buffer
    n-remaining buffer size>> min :> n-chunk

    n-chunk port wait-to-write
    n-write src >c-ptr <displaced-alien> n-chunk buffer buffer-write

    n-remaining n-chunk fixnum-fast dup 0 > [
        src swap port n-write n-chunk fixnum+fast port-write
    ] [ drop ] if ; inline recursive

PRIVATE>

M: output-port stream-write
    [ dup byte-length integer>fixnum-strict ] dip check-disposed 0 port-write ;

HOOK: tell-handle os ( handle -- n )

HOOK: seek-handle os ( n seek-type handle -- )

HOOK: can-seek-handle? os ( handle -- ? )

HOOK: handle-length os ( handle -- n/f )

<PRIVATE

: port-tell ( port -- tell-handle buffer-length )
    [ handle>> tell-handle ] [ buffer>> buffer-length ] bi ; inline

PRIVATE>

M: input-port stream-tell
    check-disposed port-tell - ;

M: output-port stream-tell
    check-disposed port-tell + ;

<PRIVATE

:: do-seek-relative ( n seek-type stream -- n seek-type stream )
    ! seek-relative needs special handling here, because of the
    ! buffer.
    seek-type seek-relative eq?
    [ n stream stream-tell + seek-absolute ] [ n seek-type ] if
    stream ; inline

PRIVATE>

M: input-port stream-seek
    check-disposed
    do-seek-relative
    [ buffer>> 0 swap buffer-reset ]
    [ handle>> seek-handle ] bi ;

M: output-port stream-seek
    check-disposed
    do-seek-relative
    [ stream-flush ]
    [ handle>> seek-handle ] bi ;

M: buffered-port stream-seekable?
    handle>> can-seek-handle? ;

M: buffered-port stream-length
    handle>> handle-length [ f ] when-zero ;

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
    [ handle>> &dispose shutdown ] with-destructors ;

GENERIC: underlying-port ( stream -- port )

M: port underlying-port ;

M: encoder underlying-port stream>> underlying-port ;

M: decoder underlying-port stream>> underlying-port ;

GENERIC: underlying-handle ( stream -- handle )

M: object underlying-handle underlying-port handle>> ;

! Fast-path optimization

HINTS: (decode-until)
    { string input-port object } ;
