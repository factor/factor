! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io io.streams.plain kernel accessors math math.order
growable destructors combinators sequences.private io.private ;
IN: io.streams.sequence

! Readers
SLOT: underlying
SLOT: i

: >sequence-stream< ( stream -- i underlying )
    [ i>> ] [ underlying>> ] bi ; inline

: next ( stream -- )
    [ 1 + ] change-i drop ; inline

: sequence-read1 ( stream -- elt/f )
    [ >sequence-stream< ?nth ] [ next ] bi ; inline

: (sequence-read-length) ( n buf stream -- buf count )
    [ underlying>> length ] [ i>> ] bi - rot min ; inline

: <sequence-copy> ( dest n i src -- n copy )
    [ 0 ] 3curry dip <copy> ; inline

: (sequence-read) ( n buf stream -- count )
    [ (sequence-read-length) ]
    [ [ dup pick + ] change-i underlying>> ] bi
    [ <sequence-copy> (copy) drop ] 2curry keep ; inline

: sequence-read-unsafe ( n buf stream -- count )
    dup >sequence-stream< bounds-check?
    [ (sequence-read) ] [ 3drop 0 ] if ; inline

: find-sep ( seps stream -- sep/f n )
    swap [ >sequence-stream< swap tail-slice ] dip
    [ member-eq? ] curry [ find swap ] curry keep
    over [ drop ] [ nip length ] if ; inline

: sequence-read-until ( separators stream -- seq sep/f )
    [ find-sep ] keep
    [ [ sequence-read-unsafe ] (read-into-new) ] [ next ] bi swap ; inline

! Writers
M: growable dispose drop ;

M: growable stream-write1 push ;
M: growable stream-write push-all ;
M: growable stream-flush drop ;

INSTANCE: growable output-stream
INSTANCE: growable plain-writer

! Seeking
: (stream-seek) ( n seek-type stream -- )
    swap {
        { seek-absolute [ i<< ] }
        { seek-relative [ [ + ] change-i drop ] }
        { seek-end [ [ underlying>> length + ] [ i<< ] bi ] }
        [ bad-seek-type ]
    } case ;
