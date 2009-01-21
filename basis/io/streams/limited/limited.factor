! Copyright (C) 2008 Slava Pestov.
! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math io io.encodings destructors accessors
sequences namespaces byte-vectors fry combinators ;
IN: io.streams.limited

TUPLE: limited-stream stream count limit mode ;

SINGLETONS: stream-throws stream-eofs ;

: <limited-stream> ( stream limit mode -- stream' )
    limited-stream new
        swap >>mode
        swap >>limit
        swap >>stream
        0 >>count ;

GENERIC# limit 2 ( stream limit mode -- stream' )

M: decoder limit ( stream limit mode -- stream' )
    [ clone ] 2dip '[ _ _ limit ] change-stream ;

M: object limit ( stream limit mode -- stream' )
    <limited-stream> ;

: unlimit ( stream -- stream' )
    [ stream>> ] change-stream ;

: limit-input ( limit mode -- ) input-stream [ -rot limit ] change ;

: unlimit-input ( -- ) input-stream [ unlimit ] change ;

ERROR: limit-exceeded ;

ERROR: bad-stream-mode mode ;

<PRIVATE

: adjust-limit ( n stream -- n' stream )
    2dup [ + ] change-count
    [ count>> ] [ limit>> ] bi >
    [
        dup mode>> {
            { stream-throws [ limit-exceeded ] }
            { stream-eofs [ 
                dup [ count>> ] [ limit>> ] bi -
                '[ _ - ] dip
            ] }
            [ bad-stream-mode ]
        } case
    ] when ; inline

: maybe-read ( n limited-stream quot: ( n stream -- seq/f ) -- seq/f )
    [ adjust-limit ] dip
    pick 0 <= [ 3drop f ] [ [ stream>> ] dip call ] if ; inline

PRIVATE>

M: limited-stream stream-read1
    1 swap 
    [ nip stream-read1 ] maybe-read ;

M: limited-stream stream-read
    [ stream-read ] maybe-read ;

M: limited-stream stream-read-partial
    [ stream-read-partial ] maybe-read ;

<PRIVATE

: (read-until) ( stream seps buf -- stream seps buf sep/f )
    3dup [ [ stream-read1 dup ] dip memq? ] dip
    swap [ drop ] [ push (read-until) ] if ;

PRIVATE>

M: limited-stream stream-read-until
    swap BV{ } clone (read-until) [ 2nip B{ } like ] dip ;

M: limited-stream dispose
    stream>> dispose ;
