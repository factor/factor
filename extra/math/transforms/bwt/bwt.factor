! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: arrays fry kernel math sequences sequences.extras
sorting ;
IN: math.transforms.bwt

! Inefficient versions of Burrows-Wheeler Transform

: bwt ( seq -- newseq )
    0 suffix all-rotations natural-sort [ last ] map ;

: ibwt ( newseq -- seq )
    [ length [ { } <array> ] keep ] keep
    '[ _ [ prefix ] 2map natural-sort ] times
    [ { 0 } tail? ] find nip but-last ;
