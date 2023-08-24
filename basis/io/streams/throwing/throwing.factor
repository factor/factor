! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors destructors io kernel math namespaces sequences ;
IN: io.streams.throwing

ERROR: stream-exhausted n stream word ;

TUPLE: throws-on-eof-stream stream ;
INSTANCE: throws-on-eof-stream input-stream

C: <throws-on-eof-stream> throws-on-eof-stream

M: throws-on-eof-stream stream-element-type stream>> stream-element-type ;

M: throws-on-eof-stream dispose stream>> dispose ;

M:: throws-on-eof-stream stream-read1 ( stream -- obj )
    stream stream>> stream-read1
    [ 1 stream \ read1 stream-exhausted ] unless* ;

M:: throws-on-eof-stream stream-read-unsafe ( n buf stream -- count )
    n buf stream stream>> stream-read-unsafe
    dup n = [ n stream \ stream-read-unsafe stream-exhausted ] unless ;

M:: throws-on-eof-stream stream-read-partial-unsafe ( n buf stream -- count )
    n buf stream stream>> stream-read-partial-unsafe
    [ n stream \ stream-read-partial-unsafe stream-exhausted ] when-zero ;

M: throws-on-eof-stream stream-tell
    stream>> stream-tell ;

M: throws-on-eof-stream stream-seek
    stream>> stream-seek ;

M: throws-on-eof-stream stream-seekable?
    stream>> stream-seekable? ;

M: throws-on-eof-stream stream-length
    stream>> stream-length ;

M: throws-on-eof-stream stream-read-until
    [ stream>> stream-read-until ]
    [ '[ length _ \ read-until stream-exhausted ] unless* ] bi ;

: stream-throw-on-eof ( ..a stream quot: ( ..a stream' -- ..b ) -- ..b )
    [ <throws-on-eof-stream> ] dip with-input-stream* ; inline

: throw-on-eof ( ..a quot: ( ..a -- ..b ) -- ..b )
    [ input-stream get <throws-on-eof-stream> ] dip with-input-stream* ; inline
