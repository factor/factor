! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel namespaces sequences
sets
compiler.cfg
compiler.cfg.dataflow-analysis
compiler.cfg.def-use
compiler.cfg.gvn.graph
compiler.cfg.predecessors
compiler.cfg.renaming.functor
compiler.cfg.rpo
compiler.utilities ;
IN: compiler.cfg.gvn.avail

: defined ( bb -- vregs )
    instructions>> [ defs-vregs ] map concat unique ;

! This doesn't propagate across "kill blocks".  Not sure if
! that's right, though I may as well assume as much.

FORWARD-ANALYSIS: avail

M: avail transfer-set drop defined assoc-union ;

: available? ( vn -- ? ) basic-block get avail-in key? ;

: best-vreg ( available-vregs -- vreg )
    [ f ] [ infimum ] if-empty ;

: >avail-vreg ( vreg -- vreg/f )
    final-iteration? get [
        congruence-class [ available? ] filter best-vreg
    ] when ;

: available-uses? ( insn -- ? )
    uses-vregs [ >avail-vreg ] all? ;

: with-available-uses? ( quot -- ? )
    keep swap [ available-uses? ] [ drop f ] if ; inline

: make-available ( vreg -- )
    basic-block get avail-ins get [ dupd clone ?set-at ] assocs:change-at ;

RENAMING: >avail [ ] [ dup >avail-vreg swap or ] [ ]
