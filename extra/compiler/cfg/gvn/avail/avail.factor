! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel namespaces sequences
sets
compiler.cfg
compiler.cfg.dataflow-analysis
compiler.cfg.def-use
compiler.cfg.gvn.graph
compiler.cfg.predecessors
compiler.cfg.rpo ;
FROM: namespaces => set ;
IN: compiler.cfg.gvn.avail

: defined ( bb -- vregs )
    instructions>> [ defs-vregs ] map concat unique ;

! This doesn't propagate across "kill blocks".  Not sure if
! that's right, though I may as well assume as much.

FORWARD-ANALYSIS: avail

M: avail-analysis transfer-set drop defined assoc-union ;

! Strict idea of availability, for now.  Would like to see if
! searching the VN congruence classes for the smallest
! available vn would work at all / better.

: available? ( vn -- ? )
    final-iteration? get [
        basic-block get avail-ins get at key?
    ] [ drop t ] if ;

: available-uses? ( insn -- ? )
    uses-vregs [ available? ] all? ;

: with-available-uses? ( quot -- ? )
    [ available-uses? ] bi and ; inline

: make-available ( insn -- insn )
    dup dst>>
    basic-block get avail-ins get [ dupd ?set-at ] change-at ;
