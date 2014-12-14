! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities
cpu.architecture deques dlists fry kernel locals namespaces
sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.liveness

SYMBOL: live-ins

: live-in ( bb -- set )
    live-ins get at ;

SYMBOL: live-outs

: live-out ( bb -- set )
    live-outs get at ;

SYMBOL: edge-live-ins

: edge-live-in ( predecessor basic-block -- set )
    edge-live-ins get at at ;

SYMBOL: base-pointers

GENERIC: visit-insn ( live-set insn -- live-set )

! If liveness analysis is run after SSA destruction, we need to
! kill vregs that have been coalesced with others (they won't
! have been renamed from their original values in the CFG).
! Otherwise, we get a bunch of stray uses that wind up
! live-in/out when they shouldn't be.  However, we must take
! care to still report the original vregs in the live-sets,
! because they have information associated with them (like
! representations) that would get lost if we just used the
! leaders for everything.

: kill-defs ( live-set insn -- live-set )
    defs-vregs [
        ?leader '[ drop ?leader _ eq? not ] assoc-filter!
    ] each ; inline

: gen-uses ( live-set insn -- live-set )
    uses-vregs [ over conjoin ] each ; inline

M: vreg-insn visit-insn
    [ kill-defs ] [ gen-uses ] bi ;

DEFER: lookup-base-pointer

GENERIC: lookup-base-pointer* ( vreg insn -- vreg/f )

M: ##tagged>integer lookup-base-pointer* nip src>> ;

M: ##unbox-any-c-ptr lookup-base-pointer*
    ! If the input to unbox-any-c-ptr was an alien and not a
    ! byte array, then the derived pointer will be outside of
    ! the data heap. The GC has to handle this case and ignore
    ! it.
    nip src>> ;

M: ##copy lookup-base-pointer* nip src>> lookup-base-pointer ;

M: ##add-imm lookup-base-pointer* nip src1>> lookup-base-pointer ;

M: ##sub-imm lookup-base-pointer* nip src1>> lookup-base-pointer ;

M: ##parallel-copy lookup-base-pointer* values>> value-at ;

M: ##add lookup-base-pointer*
    ! If both operands have a base pointer, then the user better
    ! not be doing memory reads and writes on the object, since
    ! we don't give it a base pointer in that case at all.
    nip [ src1>> ] [ src2>> ] bi [ lookup-base-pointer ] bi@ xor ;

M: ##sub lookup-base-pointer*
    nip src1>> lookup-base-pointer ;

M: vreg-insn lookup-base-pointer* 2drop f ;

! Can't use cache here because of infinite recursion inside
! the quotation passed to cache
: lookup-base-pointer ( vreg -- vregs/f )
    base-pointers get ?at [
        f over base-pointers get set-at
        [ dup ?leader insn-of lookup-base-pointer* ] keep
        dupd base-pointers get set-at
    ] unless ;


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
    <hashed-dlist> work-list set
    H{ } clone live-ins set
    H{ } clone edge-live-ins set
    H{ } clone live-outs set
    H{ } clone base-pointers set

    [ needs-predecessors ]
    [ compute-insns ]
    [ post-order add-to-work-list ] tri
    work-list get [ liveness-step ] slurp-deque ;

: live-in? ( vreg bb -- ? ) live-in key? ;

: live-out? ( vreg bb -- ? ) live-out key? ;
