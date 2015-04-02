! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators compiler.cfg.dataflow-analysis
compiler.cfg.stacks.local kernel namespaces sequences sets ;
IN: compiler.cfg.stacks.global

: peek-set ( bb -- assoc ) peek-sets get at ;
: replace-set ( bb -- assoc ) replace-sets get at ;
: kill-set ( bb -- assoc ) kill-sets get at ;

! Should exists somewhere else
: refine ( sets -- set )
    [ f ] [ [ ] [ intersect ] map-reduce ] if-empty ;

: transfer-peeked-locs ( set bb -- set' )
    [ replace-set diff ] [ peek-set union ] bi ;

! A stack location is anticipated at a location if every path from
! the location to an exit block will read the stack location
! before writing it.
BACKWARD-ANALYSIS: anticip

M: anticip-analysis transfer-set drop transfer-peeked-locs ;
M: anticip-analysis join-sets 2drop refine ;

! A stack location is live at a location if some path from
! the location to an exit block will read the stack location
! before writing it.
BACKWARD-ANALYSIS: live

M: live-analysis transfer-set drop transfer-peeked-locs ;
M: live-analysis join-sets 2drop combine ;

! A stack location is available at a location if all paths from
! the entry block to the location load the location into a
! register.
FORWARD-ANALYSIS: avail

M: avail-analysis transfer-set
    drop [ peek-set ] [ replace-set ] bi union union ;
M: avail-analysis join-sets 2drop refine ;

! A stack location is pending at a location if all paths from
! the entry block to the location write the location.
FORWARD-ANALYSIS: pending

M: pending-analysis transfer-set
    drop replace-set union ;
M: pending-analysis join-sets 2drop refine ;

! A stack location is dead at a location if no paths from the
! location to the exit block read the location before writing it.
BACKWARD-ANALYSIS: dead

M: dead-analysis transfer-set
    drop [ kill-set ] [ replace-set ] bi union union ;
M: dead-analysis join-sets 2drop refine ;
