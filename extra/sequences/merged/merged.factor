! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math sequences ;
IN: sequences.merged

TUPLE: merged seqs ;
C: <merged> merged

: <2merged> ( seq1 seq2 -- merged ) 2array <merged> ;
: <3merged> ( seq1 seq2 seq3 -- merged ) 3array <merged> ;

: merge ( seqs -- seq )
    dup <merged> swap first like ;

: 2merge ( seq1 seq2 -- seq )
    dupd <2merged> rot like ;

: 3merge ( seq1 seq2 seq3 -- seq )
    pick >r <3merged> r> like ;

M: merged length seqs>> [ length ] map sum ;

M: merged virtual@ ( n seq -- n' seq' )
    seqs>> [ length /mod ] [ nth ] bi ;

INSTANCE: merged virtual-sequence
