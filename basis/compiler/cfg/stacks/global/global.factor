! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel combinators compiler.cfg.dataflow-analysis
compiler.cfg.stacks.local ;
IN: compiler.cfg.stacks.global

! Peek analysis. Peek-in is the set of all locations anticipated at
! the start of a basic block.
BACKWARD-ANALYSIS: peek

M: peek-analysis transfer-set drop [ replace-set assoc-diff ] keep peek-set assoc-union ;

! Replace analysis. Replace-in is the set of all locations which
! will be overwritten at some point after the start of a basic block.
FORWARD-ANALYSIS: replace

M: replace-analysis transfer-set drop replace-set assoc-union ;

! Availability analysis. Avail-out is the set of all locations
! in registers at the end of a basic block.
FORWARD-ANALYSIS: avail

M: avail-analysis transfer-set drop [ peek-set ] [ replace-set ] bi assoc-union assoc-union ;

! Kill analysis. Kill-in is the set of all locations
! which are going to be overwritten.
BACKWARD-ANALYSIS: kill

M: kill-analysis transfer-set drop kill-set assoc-union ;

! Main word
: compute-global-sets ( cfg -- cfg' )
    {
        [ compute-peek-sets ]
        [ compute-replace-sets ]
        [ compute-avail-sets ]
        [ compute-kill-sets ]
        [ ]
    } cleave ;