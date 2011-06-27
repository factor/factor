! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg
compiler.cfg.dataflow-analysis
compiler.cfg.def-use
compiler.cfg.predecessors compiler.cfg.rpo deques dlists
hashtables kernel locals namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.gvn.avail

: defined ( bb -- vregs )
    instructions>> [ defs-vregs ] map concat unique ;

! This doesn't propagate across "kill blocks".  Not sure if
! that's right, though I may as well assume as much.

FORWARD-ANALYSIS: avail

M: avail-analysis transfer-set drop defined assoc-union ;

: available? ( vn -- ? )
    basic-block get avail-ins get at key? ;

: make-available ( insn -- insn )
    dup dst>>
    basic-block get avail-ins get [ dupd ?set-at ] change-at ;
