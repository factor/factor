! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors delegate delegate.protocols destructors io
kernel math sequences ;
IN: io.streams.counting

TUPLE: counting-stream stream { in-count integer initial: 0 } { out-count integer initial: 0 } ;
INSTANCE: counting-stream input-stream
INSTANCE: counting-stream output-stream

: <counting-stream> ( stream -- counting-stream )
    counting-stream new
        swap >>stream ; inline

CONSULT: input-stream-protocol counting-stream stream>> ;
CONSULT: output-stream-protocol counting-stream stream>> ;

M: counting-stream dispose stream>> dispose ;

M:: counting-stream stream-read1 ( stream -- obj )
    stream stream>> stream-read1
    dup [ stream [ 1 + ] change-in-count drop ] when ;

M:: counting-stream stream-read-unsafe ( n buf stream -- count )
    n buf stream stream>> stream-read-unsafe :> count
    stream [ count + ] change-in-count drop
    count ;

M:: counting-stream stream-read-partial-unsafe ( n buf stream -- count )
    n buf stream stream>> stream-read-partial-unsafe :> count
    stream [ count + ] change-in-count drop
    count ;

M:: counting-stream stream-read-until ( seps stream -- seq sep/f )
    seps stream stream>> stream-read-until :> ( seq sep )
    sep [ stream [ seq length + ] change-in-count drop ] when
    seq sep ;

M:: counting-stream stream-write1 ( elt stream -- )
    elt stream stream>> stream-write1
    stream [ 1 + ] change-out-count drop ;

M:: counting-stream stream-write ( data stream -- )
    data stream stream>> stream-write
    stream [ data length + ] change-out-count drop ;

M:: counting-stream stream-contents* ( stream -- seq )
    stream stream>> stream-contents :> seq
    stream [ seq length + ] change-in-count drop
    seq ;

: with-counting-stream ( stream quot -- in-count out-count )
    [ <counting-stream> ] dip [ with-input-stream ] keepd [ in-count>> ] [ out-count>> ] bi ; inline

