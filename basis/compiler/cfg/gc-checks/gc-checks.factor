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
    dup kill-block?>>
    [ drop f ] [ instructions>> [ ##allocation? ] any? ] if ;

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

! Any ##phi instructions at the start of bb are transplanted
! into the gc-check block.

: <gc-check> ( phis size -- bb )
    [ <basic-block> ] 2dip
    [
        [ % ]
        [
            cc<= int-rep next-vreg-rep int-rep next-vreg-rep
            ##check-nursery-branch
        ] bi*
    ] V{ } make >>instructions ;

: scrubbed ( uninitialized-locs -- scrub-d scrub-r )
    [ ds-loc? ] partition [ [ n>> ] map ] bi@ ;

: <gc-call> ( uninitialized-locs gc-roots -- bb )
    [ <basic-block> ] 2dip
    [ [ scrubbed ] dip ##gc-map ##call-gc ##branch ] V{ } make
    >>instructions t >>unlikely? ;

:: insert-guard ( body check bb -- )
    bb predecessors>> check predecessors<<
    V{ bb body }      check successors<<

    V{ check }        body predecessors<<
    V{ bb }           body successors<<

    V{ check body }   bb predecessors<<

    check predecessors>> [ bb check update-successors ] each ;

: (insert-gc-check) ( uninitialized-locs gc-roots phis size bb -- )
    [ [ <gc-call> ] 2dip <gc-check> ] dip insert-guard ;

GENERIC: allocation-size* ( insn -- n )

M: ##allot allocation-size* size>> ;

M: ##box-alien allocation-size* drop 5 cells ;

M: ##box-displaced-alien allocation-size* drop 5 cells ;

: allocation-size ( bb -- n )
    instructions>>
    [ ##allocation? ] filter
    [ allocation-size* data-alignment get align ] map-sum ;

: gc-live-in ( bb -- vregs )
    [ live-in keys ] [ instructions>> [ ##phi? ] filter [ dst>> ] map ] bi
    append ;

: live-tagged ( bb -- vregs )
    gc-live-in [ rep-of tagged-rep? ] filter ;

: remove-phis ( bb -- phis )
    [ [ ##phi? ] partition ] change-instructions drop ;

: insert-gc-check ( bb -- )
    {
        [ uninitialized-locs ]
        [ live-tagged ]
        [ remove-phis ]
        [ allocation-size ]
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
