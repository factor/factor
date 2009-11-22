! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.order sequences
sequences.private ;
IN: sequences.merged

TUPLE: merged seqs ;
C: <merged> merged

: <2merged> ( seq1 seq2 -- merged ) 2array <merged> ;
: <3merged> ( seq1 seq2 seq3 -- merged ) 3array <merged> ;

: merge ( seqs -- seq )
    [ <merged> ] keep first like ;

: 2merge ( seq1 seq2 -- seq )
    [ <2merged> ] 2keep drop like ;

: 3merge ( seq1 seq2 seq3 -- seq )
    [ <3merged> ] 3keep 2drop like ;

M: merged length
    seqs>> [ [ length ] [ min ] map-reduce ] [ length ] bi * ; inline

M: merged virtual@ ( n seq -- n' seq' )
    seqs>> [ length /mod ] [ nth-unsafe ] bi ; inline

M: merged virtual-exemplar ( merged -- seq )
    seqs>> [ f ] [ first ] if-empty ; inline

INSTANCE: merged virtual-sequence
