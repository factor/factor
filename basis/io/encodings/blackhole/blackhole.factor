! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays combinators io io.encodings kernel multiline ;
IN: io.encodings.blackhole


SINGLETON: blackhole

<PRIVATE

M: blackhole encode-char ( char stream encoding -- )
    drop swap drop { } >byte-array swap stream-write ;

M: blackhole decode-char ( stream encoding -- char/f )
    drop stream-read1
    {
        { [ dup not ] [ drop f ] }
        [ drop replacement-char ]
    } cond ;


PRIVATE>