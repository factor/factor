! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel accessors assocs fry locals combinators
deques dlists namespaces sequences sets compiler.cfg
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.ssa.destruction
compiler.cfg.utilities compiler.cfg.predecessors
compiler.cfg.rpo cpu.architecture ;
FROM: namespaces => set ;
IN: compiler.cfg.liveness

! Similar to http://en.wikipedia.org/wiki/Liveness_analysis,
! with three additions:

! 1) With SSA, it is not sufficient to have a single live-in set
! per block. There is also there is an edge-live-in set per
! edge, consisting of phi inputs from each predecessor.
! 2) Liveness analysis annotates call sites with GC maps
! indicating the spill slots in the stack frame that contain
! tagged pointers, and thus have to be visited if a GC occurs
! inside the call.
! 3) GC maps can contain derived pointers. A derived pointer is
! a pointer into the middle of a data heap object. Each derived
! pointer has a base pointer, to keep it up to date when objects
! are moved by the garbage collector. This extends live
! intervals and inserts new ##phi instructions.
SYMBOL: live-ins

: live-in ( bb -- set )
    live-ins get at ;

SYMBOL: live-outs

: live-out ( bb -- set )
    live-outs get at ;

! Assoc mapping basic blocks to sequences of sets of vregs; each
! sequence is in correspondence with a predecessor
SYMBOL: edge-live-ins

: edge-live-in ( predecessor basic-block -- set )
    edge-live-ins get at at ;

SYMBOL: base-pointers

GENERIC: visit-insn ( live-set insn -- live-set )

! If liveness analysis is run after SSA destruction, we need to
! use the canonical vreg representatives (leaders) because SSA
! destruction does not rename the old vregs.

: kill-defs ( live-set insn -- live-set )
    defs-vregs [
        [ leader ] keep or over delete-at
    ] each ; inline

: gen-uses ( live-set insn -- live-set )
    uses-vregs [
        [ leader ] keep or over conjoin
    ] each ; inline

M: vreg-insn visit-insn
    [ kill-defs ] [ gen-uses ] bi ;

DEFER: lookup-base-pointer

GENERIC: lookup-base-pointer* ( insn -- vreg/f )

M: ##tagged>integer lookup-base-pointer* src>> ;

M: ##unbox-any-c-ptr lookup-base-pointer*
    ! If the input to unbox-any-c-ptr was an alien and not a
    ! byte array, then the derived pointer will be outside of
    ! the data heap. The GC has to handle this case and ignore
    ! it.
    src>> ;

M: ##copy lookup-base-pointer* src>> lookup-base-pointer ;

M: ##add-imm lookup-base-pointer* src1>> lookup-base-pointer ;

M: ##sub-imm lookup-base-pointer* src1>> lookup-base-pointer ;

M: ##add lookup-base-pointer*
    ! If both operands have a base pointer, then the user better
    ! not be doing memory reads and writes on the object, since
    ! we don't give it a base pointer in that case at all.
    [ src1>> ] [ src2>> ] bi [ lookup-base-pointer ] bi@ xor ;

M: ##sub lookup-base-pointer*
    src1>> lookup-base-pointer ;

M: vreg-insn lookup-base-pointer* drop f ;

: lookup-base-pointer ( vreg -- vreg/f )
    base-pointers get [ insn-of lookup-base-pointer* ] cache ;

:: visit-derived-root ( vreg derived-roots gc-roots -- )
    vreg lookup-base-pointer :> base
    base [
        { vreg base } derived-roots push
        base gc-roots adjoin
    ] when ;

: visit-gc-root ( vreg derived-roots gc-roots -- )
    pick rep-of {
        { tagged-rep [ nip adjoin ] }
        { int-rep [ visit-derived-root ] }
        [ 4drop ]
    } case ;

: gc-roots ( live-set -- derived-roots gc-roots )
    V{ } clone HS{ } clone
    [ '[ drop _ _ visit-gc-root ] assoc-each ] 2keep
    members ;

: fill-gc-map ( live-set insn -- live-set )
    [ representations get [ dup gc-roots ] [ f f ] if ] dip
    gc-map>> [ gc-roots<< ] [ derived-roots<< ] bi ;

M: gc-map-insn visit-insn
    [ kill-defs ] [ fill-gc-map ] [ gen-uses ] tri ;

M: ##phi visit-insn kill-defs ;

M: insn visit-insn drop ;

: transfer-liveness ( live-set instructions -- live-set' )
    [ clone ] [ <reversed> ] bi* [ visit-insn ] each ;

SYMBOL: work-list

: add-to-work-list ( basic-blocks -- )
    work-list get push-all-front ;

: compute-live-in ( basic-block -- live-in )
    [ live-out ] keep instructions>> transfer-liveness ;

: compute-edge-live-in ( basic-block -- edge-live-in )
    H{ } clone [
        '[ inputs>> [ swap _ conjoin-at ] assoc-each ] each-phi
    ] keep ;

: update-live-in ( basic-block -- changed? )
    [ [ compute-live-in ] keep live-ins get maybe-set-at ]
    [ [ compute-edge-live-in ] keep edge-live-ins get maybe-set-at ]
    bi or ;

: compute-live-out ( basic-block -- live-out )
    [ successors>> [ live-in ] map ]
    [ dup successors>> [ edge-live-in ] with map ] bi
    append assoc-combine ;

: update-live-out ( basic-block -- changed? )
    [ compute-live-out ] keep
    live-outs get maybe-set-at ;

: liveness-step ( basic-block -- )
    dup update-live-out [
        dup update-live-in
        [ predecessors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-live-sets ( cfg -- )
    needs-predecessors
    dup compute-insns

    <hashed-dlist> work-list set
    H{ } clone live-ins set
    H{ } clone edge-live-ins set
    H{ } clone live-outs set
    H{ } clone base-pointers set
    post-order add-to-work-list
    work-list get [ liveness-step ] slurp-deque ;

: live-in? ( vreg bb -- ? ) live-in key? ;

: live-out? ( vreg bb -- ? ) live-out key? ;
