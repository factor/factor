! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors assocs fry kernel math sequences
sequences.rotated sorting suffix-arrays.private ;
IN: math.transforms.bwt

! Semi-efficient versions of Burrows-Wheeler Transform

: bwt* ( seq -- newseq )
    [
        dup suffixes natural-sort
        [ dup from>> [ to>> ] [ nip ] if-zero 1 - over nth ]
    ] [ map-as ] bi nip ;

: bwt ( seq -- i newseq )
    dup all-rotations natural-sort
    [ [ sequence= ] with find drop ]
    [ [ last ] rot map-as ] 2bi ;

: ibwt ( i newseq -- seq )
    [ length ]
    [ <enum> sort-values '[ _ nth first2 ] ]
    [ replicate-as ] tri nip ;
