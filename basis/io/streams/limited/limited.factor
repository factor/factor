! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math io io.encodings destructors accessors
sequences namespaces byte-vectors fry ;
IN: io.streams.limited

TUPLE: limited-stream stream count limit no-throw? ;

: <limited-stream> ( stream limit -- stream' )
    limited-stream new
        swap >>limit
        swap >>stream
        0 >>count ;

GENERIC# limit 1 ( stream limit -- stream' )

M: decoder limit [ clone ] dip [ limit ] curry change-stream ;

M: object limit <limited-stream> ;

: limit-input ( limit -- ) input-stream [ swap limit ] change ;

ERROR: limit-exceeded ;

: adjust-limit ( n stream -- n' stream )
    2dup [ + ] change-count
    [ count>> ] [ limit>> ] bi >
    [
        dup no-throw?>> [
            dup [ count>> ] [ limit>> ] bi -
            '[ _ - ] dip
        ] [
            limit-exceeded
        ] if
    ] when ; inline

: maybe-read ( n limited-stream quot: ( n stream -- seq/f ) -- seq/f )
    pick 0 <= [ 3drop f ] [ [ stream>> ] dip call ] if ; inline

M: limited-stream stream-read1
    1 swap adjust-limit
    [ nip stream-read1 ] maybe-read ;

M: limited-stream stream-read
    adjust-limit [ stream-read ] maybe-read ;

M: limited-stream stream-read-partial
    adjust-limit [ stream-read-partial ] maybe-read ;

: (read-until) ( stream seps buf -- stream seps buf sep/f )
    3dup [ [ stream-read1 dup ] dip memq? ] dip
    swap [ drop ] [ push (read-until) ] if ;

M: limited-stream stream-read-until
    swap BV{ } clone (read-until) [ 2nip B{ } like ] dip ;

M: limited-stream dispose
    stream>> dispose ;
