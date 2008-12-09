! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math io io.encodings destructors accessors
sequences namespaces byte-vectors ;
IN: io.streams.limited

TUPLE: limited-stream stream count limit ;

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

: check-limit ( n stream -- )
    [ + ] change-count
    [ count>> ] [ limit>> ] bi >=
    [ limit-exceeded ] when ; inline

M: limited-stream stream-read1
    1 over check-limit stream>> stream-read1 ;

M: limited-stream stream-read
    2dup check-limit stream>> stream-read ;

M: limited-stream stream-read-partial
    2dup check-limit stream>> stream-read-partial ;

: (read-until) ( stream seps buf -- stream seps buf sep/f )
    3dup [ [ stream-read1 dup ] dip memq? ] dip
    swap [ drop ] [ push (read-until) ] if ;

M: limited-stream stream-read-until
    swap BV{ } clone (read-until) [ 2nip B{ } like ] dip ;

M: limited-stream dispose
    stream>> dispose ;
