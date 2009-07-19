! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: compiler.cfg.dcn

! "DeConcatenatizatioN" -- dataflow analysis to recover registers
! from stack locations.

! Local sets:
! - P(b): locations that block b peeks before replacing
! - R(b): locations that block b replaces
! - A(b): P(b) \/ R(b) -- locations that are available in registers at the end of b

! Global sets:
! - P_out(b) = /\ P_in(sux) for sux in successors(b)
! - P_in(b) = (P_out(b) - R(b)) \/ P(b)
!
! - R_in(b) = R_out(b) \/ R(b)
! - R_out(b) = \/ R_in(sux) for sux in successors(b)
!
! - A_in(b) = /\ A_out(pred) for pred in predecessors(b)
! - A_out(b) = A_in(b) \/ P(b) \/ R(b)

! On every edge [b --> sux], insert a replace for each location in
! R_out(b) - R_in(sux)

! On every edge [pred --> b], insert a peek for each location in
! P_in(b) - (P_out(pred) \/ A_out(pred))

! Locations are height-normalized.