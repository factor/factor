! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io kernel accessors math math.order ;
IN: io.streams.sequence

SLOT: underlying
SLOT: i

: >sequence-stream< ( stream -- i underlying )
    [ i>> ] [ underlying>> ] bi ; inline

: next ( stream -- )
    [ 1+ ] change-i drop ;

: sequence-read1 ( stream -- elt/f )
    [ >sequence-stream< ?nth ]
    [ next ] bi ; inline

: add-length ( n stream -- i+n )
    [ i>> + ] [ underlying>> length ] bi min  ;

: (sequence-read) ( n stream -- seq/f )
    [ add-length ] keep
    [ [ swap dup ] change-i drop ]
    [ underlying>> ] bi
    subseq ; inline

: sequence-read ( n stream -- seq/f )
    dup >sequence-stream< bounds-check?
    [ (sequence-read) ] [ 2drop f ] if ; inline

: find-sep ( seps stream -- sep/f n )
    swap [ >sequence-stream< ] dip
    [ memq? ] curry find-from swap ; inline

: sequence-read-until ( separators stream -- seq sep/f )
    [ find-sep ] keep
    [ sequence-read ] [ next ] bi swap ; inline
