! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
destructors io io.private kernel locals math sequences
vectors ;
IN: io.streams.peek

TUPLE: peek-stream stream peeked ;

M: peek-stream dispose stream>> dispose ;

: stream-exemplar-growable ( stream -- exemplar )
    stream-element-type {
        { +byte+ [ BV{ } ] }
        { +character+ [ SBUF" " ] }
    } case ; inline

: stream-new-resizable ( n stream -- exemplar )
    stream-element-exemplar new-resizable ; inline

: stream-like ( sequence stream -- sequence' )
    stream-element-exemplar like ; inline

: stream-clone-resizable ( sequence stream -- sequence' )
    stream-exemplar-growable clone-like ; inline

: <peek-stream> ( stream -- stream )
    peek-stream new
        swap >>stream
        64 over stream-new-resizable >>peeked ; inline

M: peek-stream stream-element-type
    stream>> stream-element-type ;

M: peek-stream stream-read1
    dup peeked>> [
        stream>> stream-read1
    ] [
        pop nip
    ] if-empty ;

M:: peek-stream stream-read ( n stream -- sequence )
    stream peeked>> :> peeked
    peeked length :> #peeked
    #peeked 0 = [
        n stream stream>> stream-read
    ] [
        ! Have we already peeked enough?
        #peeked n > [
            peeked <reversed> n cut [ stream stream-like ]
            [ <reversed> stream stream-clone-resizable stream peeked<< ] bi*
        ] [
            peeked <reversed>
            n #peeked - stream stream>> stream-read
            stream stream-element-exemplar append-as

            stream stream-exemplar-growable clone stream peeked<<
        ] if
    ] if ;

: peek-stream-read-until ( stream seps buf -- stream seps buf sep/f )
    3dup [ [ stream-read1 dup ] dip member-eq? ] dip swap
    [ drop ] [ over [ push peek-stream-read-until ] [ drop ] if ] if ;

M: peek-stream stream-read-until
    swap 64 pick stream-new-resizable
    peek-stream-read-until [ nip swap stream-like ] dip ;

M: peek-stream stream-write stream>> stream-write ;
M: peek-stream stream-write1 stream>> stream-write1 ;
M: peek-stream stream-flush stream>> stream-flush ;

: stream-peek1 ( stream -- ch )
    dup peeked>> [
        dup stream>> stream-read1 [
            [ 1vector over stream-clone-resizable >>peeked drop ] keep
        ] [
            drop f
        ] if*
    ] [
        last nip
    ] if-empty ;

: stream-peek ( n stream -- seq )
    2dup peeked>> { [ length <= ] [ length 0 > ] } 1&& [
        [ peeked>> <reversed> swap head ] [ stream-element-exemplar like ] bi
    ] [
        [ nip ]
        [ stream-read ] 2bi
        [ reverse swap peeked>> push-all ] keep
    ] if ;
