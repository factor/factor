! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays combinators destructors growable
io io.private io.streams.plain kernel math math.order sequences
sequences.private strings ;
IN: io.streams.sequence

! Readers
SLOT: underlying
SLOT: i

: >sequence-stream< ( stream -- i underlying )
    [ i>> ] [ underlying>> ] bi ; inline

: sequence-read1 ( stream -- elt/f )
    dup >sequence-stream< dupd ?nth [ 1 + swap i<< ] dip ; inline

<PRIVATE

: (sequence-read-length) ( n buf stream -- buf count )
    [ underlying>> length ] [ i>> ] bi - rot min ; inline

: <sequence-copy> ( dst n src-i src dst-i -- n copy )
    [ ] curry 3curry dip <copy> ; inline

: sequence-copy-unsafe ( n buf stream offset -- count )
    [
        [ (sequence-read-length) ]
        [ [ dup pick + ] change-i underlying>> ] bi
    ] dip [ <sequence-copy> (copy) drop ] 3curry keep ; inline

ERROR: not-a-byte-array obj ;
: check-byte-array ( buf stream offset -- buf stream offset )
    pick byte-array? [ pick not-a-byte-array ] unless ; inline

ERROR: not-a-string obj ;
: check-string ( buf stream offset -- buf stream offset )
    pick string? [ pick not-a-string ] unless ; inline

: (sequence-read-unsafe) ( n buf stream -- count )
    [ integer>fixnum ]
    [ dup slice? [ [ seq>> ] [ from>> ] bi ] [ 0 ] if ]
    [
        tuck stream-element-type +byte+ eq?
        [ check-byte-array sequence-copy-unsafe ]
        [ check-string sequence-copy-unsafe ] if
    ] tri* ; inline

PRIVATE>

: sequence-read-unsafe ( n buf stream -- count )
    dup >sequence-stream< bounds-check?
    [ (sequence-read-unsafe) ] [ 3drop 0 ] if ; inline

<PRIVATE

: find-separator ( seps stream -- sep/f n )
    >sequence-stream< rot [ member? ] curry
    [ find-from swap ] curry 2keep pick
    [ drop - ] [ length swap - nip ] if ; inline

: (sequence-read-until) ( seps stream -- seq sep/f )
    [ find-separator ] keep
    [ [ (sequence-read-unsafe) ] (read-into-new) ]
    [ [ 1 + ] change-i drop ]
    [ stream-exemplar or ] tri swap ; inline

PRIVATE>

: sequence-read-until ( seps stream -- seq sep/f )
    dup >sequence-stream< bounds-check?
    [ (sequence-read-until) ] [ 2drop f f ] if ; inline

! Writers
M: growable dispose drop ;

M: growable stream-write1 push ;
M: growable stream-write push-all ;
M: growable stream-flush drop ;

INSTANCE: growable output-stream
INSTANCE: growable plain-writer

! Seeking
: sequence-seek ( n seek-type stream -- )
    swap {
        { seek-absolute [ i<< ] }
        { seek-relative [ [ + ] change-i drop ] }
        { seek-end [ [ underlying>> length + ] [ i<< ] bi ] }
        [ bad-seek-type ]
    } case ;
