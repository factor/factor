! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel sequences vectors
compiler.cfg.instructions
compiler.cfg.comparisons
compiler.cfg.rpo
compiler.cfg ;
IN: compiler.cfg.branch-folding

! Fold comparisons where both inputs are the same. Predecessors must be
! recomputed after this

: fold-branch? ( bb -- ? )
    instructions>> last {
        [ ##compare-branch? ]
        [ [ src1>> ] [ src2>> ] bi = ]
    } 1&& ;

: chosen-successor ( bb -- succ )
    [ instructions>> last cc>> { cc= cc<= cc>= } memq? 0 1 ? ]
    [ successors>> ]
    bi nth ;

: fold-branch ( bb -- )
    dup chosen-successor 1vector >>successors
    instructions>> [ pop* ] [ [ \ ##branch new-insn ] dip push ] bi ;

: fold-branches ( cfg -- cfg' )
    dup [
        dup fold-branch?
        [ fold-branch ] [ drop ] if
    ] each-basic-block
    cfg-changed ;