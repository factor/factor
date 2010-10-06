! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io io.streams.plain kernel accessors math math.order
growable destructors combinators ;
IN: io.streams.sequence

! Readers
SLOT: underlying
SLOT: i

: >sequence-stream< ( stream -- i underlying )
    [ i>> ] [ underlying>> ] bi ; inline

: next ( stream -- )
    [ 1 + ] change-i drop ; inline

: sequence-peek1 ( seq -- elt/f )
    [ i>> ] [ underlying>> ] bi ?nth ;

: sequence-peek ( n seq -- elt/f )
    [ nip i>> dup ] [ [ + ] [ underlying>> ] bi* ] 2bi ?subseq ;

: sequence-read1 ( stream -- elt/f )
    [ >sequence-stream< ?nth ] [ next ] bi ; inline

: add-length ( n stream -- i+n )
    [ i>> + ] [ underlying>> length ] bi min ; inline

: (sequence-read) ( n stream -- seq/f )
    [ add-length ] keep
    [ [ swap dup ] change-i drop ]
    [ underlying>> ] bi
    subseq ; inline

: sequence-read ( n stream -- seq/f )
    dup >sequence-stream< bounds-check?
    [ (sequence-read) ] [ 2drop f ] if ; inline

: find-sep ( seps stream -- sep/f n )
    swap [ >sequence-stream< swap tail-slice ] dip
    [ member-eq? ] curry find swap ; inline

: sequence-read-until ( separators stream -- seq sep/f )
    [ find-sep ] keep
    [ sequence-read ] [ next ] bi swap ; inline

! Writers
M: growable dispose drop ;

M: growable stream-write1 push ;
M: growable stream-write push-all ;
M: growable stream-flush drop ;

INSTANCE: growable plain-writer

! Seeking
: (stream-seek) ( n seek-type stream -- )
    swap {
        { seek-absolute [ i<< ] }
        { seek-relative [ [ + ] change-i drop ] }
        { seek-end [ [ underlying>> length + ] [ i<< ] bi ] }
        [ bad-seek-type ]
    } case ;
