! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.loop-detection compiler.cfg.rpo
kernel locals math math.order namespaces sequences sets ;
IN: compiler.cfg.register-allocation.chordal.spilling.next-use

! Distances count instructions, not linearized program positions. A missing
! key means no reachable use. Loop exits incur a finite penalty, following
! Braun/Hack CC 2009; this keeps an inner-loop use ahead of an exit-only use.
CONSTANT: loop-exit-distance 100000

:: merge-next-use! ( source penalty destination -- )
    source [| value distance |
        distance penalty + :> candidate
        value destination at [ candidate min ] [ candidate ] if*
        value destination set-at
    ] assoc-each ;

: spill-insn-uses ( insn -- uses )
    dup gc-map-insn? [
        [ uses-vregs ] [ gc-map>>
            [ gc-roots>> ] [ derived-roots>> [ keys ] [ values ] bi append ] bi
            append
        ] bi append members
    ] [ uses-vregs ] if ;

:: transfer-next-use ( after insn -- before )
    after [ 1 + ] assoc-map :> before
    insn defs-vregs [ before delete-at ] each
    insn ##phi? [ ] [
        insn spill-insn-uses [ 0 swap before set-at ] each
    ] if
    before ;

:: block-next-use ( after bb -- before )
    after :> state!
    bb instructions>> <reversed> [ state swap transfer-next-use state! ] each
    state ;

:: loop-exit-penalty ( from to -- distance )
    from loop-nesting-at to loop-nesting-at >
    loop-exit-distance 0 ? ;

! Ordinary live-ins retain their names. Phi uses belong only to their own
! predecessor edge, including loop backedges; they are never unioned as
! ordinary uses of the successor block.
:: edge-next-use ( from to entries -- distances )
    to entries at clone :> distances
    to instructions>> [ ##phi? ] filter [| phi |
        from phi inputs>> at 0 swap distances set-at
    ] each
    distances ;

:: successor-next-use ( bb entries -- distances )
    H{ } clone :> distances
    bb successors>> [| successor |
        bb successor entries edge-next-use
        bb successor loop-exit-penalty distances merge-next-use!
    ] each
    distances ;

! Monotone minimum-distance equations reach a fixed point even with loops:
! paths without uses stay absent, and cycling cannot improve a finite path.
:: compute-next-uses ( cfg -- entries exits )
    cfg needs-loops
    cfg reverse-post-order :> blocks
    blocks [ H{ } clone ] H{ } map>assoc :> entries
    blocks [ H{ } clone ] H{ } map>assoc :> exits
    t :> changed!
    [ changed ] [
        f changed!
        blocks <reversed> [| bb |
            bb entries successor-next-use :> after
            after bb block-next-use :> before
            before bb entries at = not [ t changed! ] when
            before bb entries set-at
            after bb exits set-at
        ] each
    ] while
    entries exits ;

:: instruction-next-uses ( bb exit -- afters )
    H{ } clone :> afters
    exit :> state!
    bb instructions>> <reversed> [| insn |
        state insn afters set-at
        state insn transfer-next-use state!
    ] each
    afters ;
