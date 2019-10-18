! Copyright (C) 2012 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.utilities kernel namespaces ;
IN: compiler.cfg.ssa.destruction.leaders

! A map from vregs to canonical representatives due to
! coalescing done by SSA destruction.  Used by liveness
! analysis and the register allocator, so we can use the
! original SSA names to get certain info (reaching definitions,
! representations).
SYMBOL: leader-map

: leader ( vreg -- vreg' ) leader-map get compress-path ;

: ?leader ( vreg -- vreg' ) [ leader ] keep or ; inline
