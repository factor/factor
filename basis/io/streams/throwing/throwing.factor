! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors destructors io kernel locals namespaces
sequences fry ;
IN: io.streams.throwing

ERROR: stream-exhausted n stream word ;

<PRIVATE

TUPLE: throws-on-eof-stream stream ;

C: <throws-on-eof-stream> throws-on-eof-stream

M: throws-on-eof-stream stream-element-type stream>> stream-element-type ;

M: throws-on-eof-stream dispose stream>> dispose ;

M:: throws-on-eof-stream stream-read1 ( stream -- obj )
    stream stream>> stream-read1
    [ 1 stream \ read1 stream-exhausted ] unless* ;

M:: throws-on-eof-stream stream-read ( n stream -- seq )
    n stream stream>> stream-read
    dup length n = [ n stream \ read stream-exhausted ] unless ;

M:: throws-on-eof-stream stream-read-partial ( n stream -- seq )
    n stream stream>> stream-read-partial
    [ n stream \ read-partial stream-exhausted ] unless* ;

M: throws-on-eof-stream stream-tell
    stream>> stream-tell ;

M: throws-on-eof-stream stream-seek
    stream>> stream-seek ;

M: throws-on-eof-stream stream-read-until
    [ stream>> stream-read-until ]
    [ '[ length _ \ read-until stream-exhausted ] unless* ] bi ;

PRIVATE>

: stream-throw-on-eof ( ..a stream quot: ( ..a stream' -- ..b ) -- ..b )
    [ <throws-on-eof-stream> ] dip call ; inline

: throw-on-eof ( ..a quot: ( ..a -- ..b ) -- ..b )
    [ input-stream get <throws-on-eof-stream> ] dip with-input-stream* ; inline
