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

: sequence-read1 ( stream -- elt/f )
    dup >sequence-stream< dupd ?nth [ 1 + swap i<< ] dip ; inline

: (sequence-read-length) ( n buf stream -- buf count )
    [ underlying>> length ] [ i>> ] bi - rot min ; inline

: <sequence-copy> ( dest n i src -- n copy )
    [ 0 ] 3curry dip <copy> ; inline

: (sequence-read-unsafe) ( n buf stream -- count )
    [ (sequence-read-length) ]
    [ [ dup pick + ] change-i underlying>> ] bi
    [ <sequence-copy> (copy) drop ] 2curry keep ; inline

: sequence-read-unsafe ( n buf stream -- count )
    dup >sequence-stream< bounds-check?
    [ (sequence-read-unsafe) ] [ 3drop 0 ] if ; inline

: find-separator ( seps stream -- sep/f n )
    swap [ >sequence-stream< ] dip
    [ member-eq? ] curry [ find-from swap ] curry 2keep
    pick [ drop - ] [ length swap - nip ] if ; inline

: sequence-read-until ( seps stream -- seq sep/f )
    [ find-separator ] keep
    [ [ (sequence-read-unsafe) ] (read-into-new) ]
    [ [ 1 + ] change-i drop ] bi swap ; inline

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
