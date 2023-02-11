! Copyright (C) 2008 Slava Pestov.
! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators destructors io io.encodings
io.files io.files.info kernel math math.order namespaces
sequences ;
IN: io.streams.limited

TUPLE: limited-stream stream count limit current start stop ;
INSTANCE: limited-stream input-stream

: <limited-stream> ( stream limit -- stream' )
    limited-stream new
        swap >>limit
        swap >>stream
        0 >>count ;

: <limited-file-reader> ( path encoding -- stream' )
    [ <file-reader> ]
    [ drop file-info size>> ] 2bi
    <limited-stream> ;

GENERIC#: limit-stream 1 ( stream limit -- stream' )

M: decoder limit-stream
    '[ stream>> _ limit-stream ] [ code>> ] [ cr>> ] tri
    decoder boa ; inline

M: object limit-stream
    <limited-stream> ;

: limited-input ( limit -- )
    [ input-stream ] dip '[ _ limit-stream ] change ;

: with-limited-stream ( stream limit quot -- )
    [ limit-stream ] dip call ; inline

: with-limited-input ( limit quot -- )
    [ [ input-stream get ] dip limit-stream input-stream ] dip
    with-variable ; inline

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

:: maybe-read-unsafe ( n buf limited-stream quot: ( n buf stream -- count ) -- count )
    n limited-stream adjust-limited-read :> ( n' lstream' )
    n' 0 <= [ 0 ] [ n' buf lstream' stream>> quot call ] if ; inline

PRIVATE>

M: limited-stream stream-read1
    1 swap
    [ nip stream-read1 ] maybe-read ;

M: limited-stream stream-read-unsafe
    [ stream-read-unsafe ] maybe-read-unsafe ;

M: limited-stream stream-read-partial-unsafe
    [ stream-read-partial-unsafe ] maybe-read-unsafe ;

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

M: limited-stream stream-seekable?
    stream>> stream-seekable? ; inline

M: limited-stream stream-length
    dup stream>> stream-length
    [ swap limit>> min ] [ drop f ] if* ; inline

M: limited-stream dispose stream>> dispose ;

M: limited-stream stream-element-type
    stream>> stream-element-type ;

GENERIC: unlimit-stream ( stream -- stream' )

M: decoder unlimit-stream
    [ stream>> stream>> ] [ code>> ] [ cr>> ] tri decoder boa ;

M: limited-stream unlimit-stream stream>> ;

: unlimited-input ( -- )
    input-stream [ unlimit-stream ] change ;

: with-unlimited-stream ( stream quot -- )
    [ unlimit-stream ] dip call ; inline

: with-unlimited-input ( quot -- )
    [ input-stream get unlimit-stream input-stream ] dip
    with-variable ; inline
