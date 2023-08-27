! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.registers
compiler.cfg.rpo compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities compiler.utilities cpu.architecture
deques dlists kernel namespaces sequences sets ;
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

GENERIC: visit-insn ( live-set insn -- )

! This would be much better if live-set was a real set
: kill-defs ( live-set insn -- )
    defs-vregs [ ?leader ] map
    '[ drop ?leader _ in? ] assoc-reject! drop ; inline

: gen-uses ( live-set insn -- )
    uses-vregs [ swap conjoin ] with each ; inline

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

M: ##parallel-copy lookup-base-pointer* values>> value-at ;

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
    keys V{ } clone HS{ } clone
    [ '[ _ _ visit-gc-root ] each ] 2keep members ;

: fill-gc-map ( live-set gc-map -- )
    [ gc-roots ] dip [ gc-roots<< ] [ derived-roots<< ] bi ;

M: gc-map-insn visit-insn
    [ kill-defs ] [ gc-map>> fill-gc-map ] [ gen-uses ] 2tri ;

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

: compute-live-out ( basic-block -- live-out )
    [ successors>> [ live-in ] map ]
    [ dup successors>> [ edge-live-in ] with map ] bi
    append assoc-union-all ;

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
    H{ } clone base-pointers namespaces:set ;

: compute-live-sets ( cfg -- )
    init-liveness
    dup needs-predecessors dup compute-insns
    post-order <hashed-dlist> [ push-all-front ] keep
    [ liveness-step ] slurp/replenish-deque ;

: live-in? ( vreg bb -- ? ) live-in key? ;

: live-out? ( vreg bb -- ? ) live-out key? ;
