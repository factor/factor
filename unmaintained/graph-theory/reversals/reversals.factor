! Copyright (C) 2008 William Schlieper <schlieper@unc.edu>
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel graph-theory ;

IN: graph-theory.reversals

TUPLE: reversal graph ;

GENERIC: reverse-graph ( graph -- reversal )

M: graph reverse-graph reversal boa ;

M: reversal reverse-graph graph>> ;

INSTANCE: reversal graph

M: reversal vertices
    graph>> vertices ;

M: reversal adj?
    swapd graph>> adj? ;
