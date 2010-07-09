! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors destructors io kernel locals namespaces
sequences ;
IN: io.streams.throwing

ERROR: stream-exhausted n stream word ;

<PRIVATE

TUPLE: throws-on-eof stream ;

C: <throws-on-eof> throws-on-eof

M: throws-on-eof stream-element-type stream>> stream-element-type ;

M: throws-on-eof dispose stream>> dispose ;

M:: throws-on-eof stream-read1 ( stream -- obj )
    stream stream>> stream-read1
    [ 1 stream \ read1 stream-exhausted ] unless* ;

M:: throws-on-eof stream-read ( n stream -- seq )
    n stream stream>> stream-read
    dup length n = [ n stream \ read stream-exhausted ] unless ;

M:: throws-on-eof stream-read-partial ( n stream -- seq )
    n stream stream>> stream-read-partial
    [ n stream \ read-partial stream-exhausted ] unless* ;

PRIVATE>

: throws-on-eof ( stream quot -- )
    [ <throws-on-eof> ] dip with-input-stream ; inline

: input-throws-on-eof ( quot -- )
    [ input-stream get <throws-on-eof> ] dip with-input-stream ; inline
