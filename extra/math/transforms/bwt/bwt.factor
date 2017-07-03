! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors assocs fry kernel locals sequences
sequences.rotated sorting ;
IN: math.transforms.bwt

! Semi-efficient versions of Burrows-Wheeler Transform

:: bwt ( seq -- i newseq )
    seq all-rotations natural-sort
    [ [ n>> 0 = ] find drop ] keep
    [ last ] seq map-as ;

: ibwt ( i newseq -- seq )
    [ length ]
    [ <enumerated> sort-values '[ _ nth first2 ] ]
    [ replicate-as ] tri nip ;
