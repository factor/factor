! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.registers
compiler.cfg.rpo compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities compiler.utilities cpu.architecture
deques dlists kernel locals namespaces sequences sets ;
IN: compiler.cfg.liveness

! Immutable per-allocation phi -> tagged-base seeds. Liveness resets only
! its derived cache; it must retain these SSA value relationships through
! CSSA copies and cleanup. The dispatcher restores the caller's seed map.
SYMBOL: initial-base-pointers

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

GENERIC: visit-insn ( live-set insn -- )

: kill-defs ( live-set insn -- )
    defs-vregs [ drop ] [
        leader-map get [
            [ ?leader ] map
            '[ drop ?leader _ in? ] assoc-reject! drop
        ] [
            ! Before coalescing there are no aliases to search for.
            [ over delete-at ] each drop
        ] if
    ] if-empty ; inline

: gen-uses ( live-set insn -- )
    uses-vregs [ swap conjoin ] with each ; inline

: gen-gc-uses ( live-set insn -- )
    gc-map>> derived-roots>> values
    [ swap conjoin ] with each ; inline

M: vreg-insn visit-insn
    [ kill-defs ] [ gen-uses ] 2bi ;

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

M: ##parallel-copy lookup-base-pointer*
    values>> at lookup-base-pointer ;

M: ##add lookup-base-pointer*
    ! If both operands have a base pointer, then the user better
    ! not be doing memory reads and writes on the object, since
    ! we don't give it a base pointer in that case at all.
    nip [ src1>> ] [ src2>> ] bi [ lookup-base-pointer ] bi@ xor ;

M: ##sub lookup-base-pointer*
    nip src1>> lookup-base-pointer ;

M: vreg-insn lookup-base-pointer* 2drop f ;

: lookup-base-pointer ( vreg -- vreg/f )
    base-pointers get ?at [
        f over base-pointers get set-at
        [
            dup insn-of [ lookup-base-pointer* ] [
                dup ?leader insn-of lookup-base-pointer*
            ] if*
        ] keep
        dupd base-pointers get set-at
    ] unless ;

! Leader equality can also mean register reuse between different values.
! Only original bit-preserving definitions prove that a derived value and
! its tagged base contain identical bits and can share a root slot.
:: same-base-bits? ( vreg base -- ? )
    vreg base = [ t ] [
        vreg insn-of :> insn
        insn ##copy? insn ##tagged>integer? or [
            insn src>> base same-base-bits?
        ] [
            insn ##parallel-copy? [
                vreg insn values>> at base same-base-bits?
            ] [ f ] if
        ] if
    ] if ;

:: visit-derived-root ( vreg derived-roots gc-roots -- )
    vreg lookup-base-pointer :> base
    base [
        ! A coalesced base already occupies the derived value's slot. A
        ! self-pair would make the collector subtract the root from itself
        ! before tracing it, replacing the live pointer with zero.
        vreg base [ ?leader ] bi@ =
        [ vreg base same-base-bits? ] [ f ] if [ ] [
            { vreg base } derived-roots push
        ] if
        base gc-roots adjoin
    ] when ;

: visit-gc-root ( vreg derived-roots gc-roots -- )
    pick rep-of {
        { tagged-rep [ nip adjoin ] }
        { int-rep [ visit-derived-root ] }
        [ 4drop ]
    } case ;

: gc-roots ( live-set -- derived-roots gc-roots )
    keys V{ } clone HS{ } clone
    [ '[ _ _ visit-gc-root ] each ] 2keep members ;

: fill-gc-map ( live-set gc-map -- )
    [ gc-roots ] dip [ gc-roots<< ] [ derived-roots<< ] bi ;

M: gc-map-insn visit-insn
    [ kill-defs ] [ gc-map>> fill-gc-map ]
    [ [ gen-gc-uses ] [ gen-uses ] 2bi ] 2tri ;

M: ##phi visit-insn kill-defs ;

M: insn visit-insn 2drop ;

: transfer-liveness ( live-set insns -- )
    <reversed> [ visit-insn ] with each ;

: compute-live-in ( basic-block -- live-in )
    [ live-out clone dup ] keep instructions>> transfer-liveness ;

: compute-edge-live-in ( basic-block -- edge-live-in )
    H{ } clone [
        '[ inputs>> [ swap _ conjoin-at ] assoc-each ] each-phi
    ] keep ;

: update-live-in ( basic-block -- changed? )
    [ [ compute-live-in ] keep live-ins get maybe-set-at ]
    [ [ compute-edge-live-in ] keep edge-live-ins get maybe-set-at ]
    bi or ;

:: compute-live-out ( basic-block -- live-out )
    H{ } clone :> result
    basic-block successors>> :> succs
    succs [ live-in result swap assoc-union! drop ] each
    succs [ basic-block swap edge-live-in result swap assoc-union! drop ] each
    result ;

: update-live-out ( basic-block -- changed? )
    [ compute-live-out ] keep
    live-outs get maybe-set-at ;

: update-live-out/in ( basic-block -- changed? )
    { [ update-live-out ] [ update-live-in ] } 1&& ;

: liveness-step ( basic-block -- basic-blocks )
    [ update-live-out/in ] keep predecessors>> { } ? ;

: init-liveness ( -- )
    H{ } clone live-ins namespaces:set
    H{ } clone edge-live-ins namespaces:set
    H{ } clone live-outs namespaces:set
    initial-base-pointers get [ clone ] [ H{ } clone ] if*
    base-pointers namespaces:set ;

: compute-live-sets-with-insns ( cfg -- )
    init-liveness
    dup needs-predecessors
    post-order <hashed-dlist> [ push-all-front ] keep
    [ liveness-step ] slurp/replenish-deque ;

: compute-live-sets ( cfg -- )
    dup compute-insns compute-live-sets-with-insns ;

: live-in? ( vreg bb -- ? ) live-in key? ;

: live-out? ( vreg bb -- ? ) live-out key? ;
