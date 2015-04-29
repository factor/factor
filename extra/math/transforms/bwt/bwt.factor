! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: assocs fry kernel sequences sequences.rotated sorting ;
IN: math.transforms.bwt

! Semi-efficient versions of Burrows-Wheeler Transform

: bwt ( seq -- i newseq )
    dup all-rotations natural-sort
    [ [ sequence= ] with find drop ]
    [ [ last ] rot map-as ] 2bi ;

: ibwt ( i newseq -- seq )
    [ length ]
    [ <enum> sort-values '[ _ nth first2 ] ]
    [ replicate-as ] tri nip ;
