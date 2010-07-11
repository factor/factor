! Copyright (C) 2008 Slava Pestov.
! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-vectors combinators destructors fry io
io.encodings io.files io.files.info kernel locals math
namespaces sequences ;
IN: io.streams.limited

TUPLE: limited-stream stream count limit current start stop ;

: <limited-stream> ( stream limit -- stream' )
    limited-stream new
        swap >>limit
        swap >>stream
        0 >>count ;

: <limited-file-reader> ( path encoding -- stream' )
    [ <file-reader> ]
    [ drop file-info size>> ] 2bi
    <limited-stream> ;

GENERIC# limit-stream 1 ( stream limit -- stream' )

M: decoder limit-stream ( stream limit -- stream' )
    [ clone ] dip '[ _ limit-stream ] change-stream ;

M: object limit-stream ( stream limit -- stream' )
    <limited-stream> ;

: limited-input ( limit -- )
    [ input-stream ] dip '[ _ limit-stream ] change ;

: with-limited-stream ( stream limit quot -- )
    [ limit-stream ] dip call ; inline

ERROR: limit-exceeded n stream ;

<PRIVATE

: adjust-current-limit ( n stream -- n' stream )
    2dup [ + ] change-current
    [ current>> ] [ stop>> ] bi >
    [
        dup [ current>> ] [ stop>> ] bi -
        '[ _ - ] dip
    ] when ; inline

: adjust-count-limit ( n stream -- n' stream )
    2dup [ + ] change-count
    [ count>> ] [ limit>> ] bi >
    [
        dup [ count>> ] [ limit>> ] bi -
        '[ _ - ] dip
        dup limit>> >>count
    ] when ; inline

: check-count-bounds ( n stream -- n stream )
    dup [ count>> ] [ limit>> ] bi >
    [ limit-exceeded ] when ;

: check-current-bounds ( n stream -- n stream )
    dup [ current>> ] [ start>> ] bi <
    [ limit-exceeded ] when ;

: adjust-limited-read ( n stream -- n stream )
    dup start>> [
        check-current-bounds adjust-current-limit
    ] [
        check-count-bounds adjust-count-limit
    ] if ;

: maybe-read ( n limited-stream quot: ( n stream -- seq/f ) -- seq/f )
    [ adjust-limited-read ] dip
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
    3dup [ [ stream-read1 dup ] dip member-eq? ] dip
    swap [
        drop
    ] [
        over [ push (read-until) ] [ drop ] if
    ] if ;

:: limited-stream-seek ( n seek-type stream -- )
    seek-type {
        { seek-absolute [ n stream current<< ] }
        { seek-relative [ stream [ n + ] change-current drop ] }
        { seek-end [ stream stop>> n - stream current<< ] }
        [ bad-seek-type ]
    } case ;

: >limited-seek ( stream -- stream' )
    dup start>> [
        dup stream-tell >>current
        dup [ current>> ] [ count>> ] bi - >>start
        dup [ start>> ] [ limit>> ] bi + >>stop
    ] unless ;

PRIVATE>

M: limited-stream stream-read-until
    swap BV{ } clone (read-until) [ 2nip B{ } like ] dip ;

M: limited-stream stream-tell
    stream>> stream-tell ;

M: limited-stream stream-seek
    >limited-seek
    [ stream>> stream-seek ]
    [ limited-stream-seek ] 3bi ;

M: limited-stream dispose stream>> dispose ;

M: limited-stream stream-element-type
    stream>> stream-element-type ;
