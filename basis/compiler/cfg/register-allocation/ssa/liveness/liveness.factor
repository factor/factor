! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.liveness compiler.cfg.predecessors compiler.cfg.rpo
compiler.cfg.utilities compiler.utilities deques dlists kernel locals namespaces sequences sets ;
IN: compiler.cfg.register-allocation.ssa.liveness

! Source spilling has already rewritten each GC map to its precise register
! or memory token. Rediscovering provenance through reloads loses the original
! derived pointer's base, so this transfer preserves and consumes that map.
:: gen-explicit-gc-uses ( live-set insn -- )
    insn gc-map>> :> map
    map gc-roots>> [ live-set conjoin ] each
    map derived-roots>> [| derived base |
        derived live-set conjoin
        base live-set conjoin
    ] assoc-each ;

: visit-ssa-insn-preserving-gc ( live-set insn -- )
    dup gc-map-insn? [
        [ kill-defs ] [ gen-uses ] [ gen-explicit-gc-uses ] 2tri
    ] [ visit-insn ] if ;

: compute-preserved-ssa-live-in ( bb -- live-in )
    [ live-out clone dup ] keep instructions>> <reversed>
    [ visit-ssa-insn-preserving-gc ] with each ;

: update-preserved-ssa-live-in ( bb -- changed? )
    [ [ compute-preserved-ssa-live-in ] keep live-ins get maybe-set-at ]
    [ [ compute-edge-live-in ] keep edge-live-ins get maybe-set-at ] bi or ;

: preserved-ssa-liveness-step ( bb -- predecessors )
    [ dup update-live-out [ update-preserved-ssa-live-in ] [ drop f ] if ]
    keep predecessors>> { } ? ;

: compute-ssa-live-sets-preserving-gc ( cfg -- )
    init-liveness
    dup needs-predecessors dup compute-insns
    post-order <hashed-dlist> [ push-all-front ] keep
    [ preserved-ssa-liveness-step ] slurp/replenish-deque ;
