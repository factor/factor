! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators fry kernel layouts locals
math make namespaces sequences cpu.architecture
compiler.cfg
compiler.cfg.rpo
compiler.cfg.hats
compiler.cfg.registers
compiler.cfg.utilities
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.predecessors
compiler.cfg.liveness
compiler.cfg.liveness.ssa
compiler.cfg.stacks.uninitialized ;
IN: compiler.cfg.gc-checks

<PRIVATE

! Garbage collection check insertion. This pass runs after
! representation selection, since it needs to know which vregs
! can contain tagged pointers.

: insert-gc-check? ( bb -- ? )
    instructions>> [ ##allocation? ] any? ;

: blocks-with-gc ( cfg -- bbs )
    post-order [ insert-gc-check? ] filter ;

! A GC check for bb consists of two new basic blocks, gc-check
! and gc-call:
!
!    gc-check
!   /      \
!  |     gc-call
!   \      /
!      bb

: <gc-check> ( size -- bb )
    [ <basic-block> ] dip
    [
        cc<= int-rep next-vreg-rep int-rep next-vreg-rep
        ##check-nursery-branch
    ] V{ } make >>instructions ;

: wipe-locs ( uninitialized-locs -- )
    '[
        int-rep next-vreg-rep
        [ 0 ##load-tagged ]
        [ '[ [ _ ] dip ##replace ] each ] bi
    ] unless-empty ;

: <gc-call> ( uninitialized-locs gc-roots -- bb )
    [ <basic-block> ] 2dip
    [ [ wipe-locs ] [ ##call-gc ] bi* ##branch ] V{ } make
    >>instructions t >>unlikely? ;

:: insert-guard ( check body bb -- )
    bb predecessors>> check (>>predecessors)
    V{ bb body }      check (>>successors)

    V{ check }        body (>>predecessors)
    V{ bb }           body (>>successors)

    V{ check body }   bb (>>predecessors)

    check predecessors>> [ bb check update-successors ] each ;

: (insert-gc-check) ( size uninitialized-locs gc-roots bb -- )
    [ [ <gc-check> ] 2dip <gc-call> ] dip insert-guard ;

GENERIC: allocation-size* ( insn -- n )

M: ##allot allocation-size* size>> ;

M: ##box-alien allocation-size* drop 5 cells ;

M: ##box-displaced-alien allocation-size* drop 5 cells ;

: allocation-size ( bb -- n )
    instructions>>
    [ ##allocation? ] filter
    [ allocation-size* data-alignment get align ] map-sum ;

: live-tagged ( bb -- vregs )
    live-in keys [ rep-of tagged-rep? ] filter ;

: insert-gc-check ( bb -- )
    {
        [ allocation-size ]
        [ uninitialized-locs ]
        [ live-tagged ]
        [ ]
    } cleave
    (insert-gc-check) ;

PRIVATE>

: insert-gc-checks ( cfg -- cfg' )
    dup blocks-with-gc [
        [
            needs-predecessors
            dup compute-ssa-live-sets
            dup compute-uninitialized-sets
        ] dip
        [ insert-gc-check ] each
        cfg-changed
    ] unless-empty ;
