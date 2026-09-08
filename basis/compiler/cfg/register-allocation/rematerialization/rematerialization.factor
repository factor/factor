! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linear-scan.live-intervals
compiler.cfg.linearization compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders cpu.architecture kernel locals
make math math.order namespaces sequences ;
IN: compiler.cfg.register-allocation.rematerialization

! Opt in until whole-bootstrap measurements justify enabling by default.
SYMBOL: rematerialize-constants?
SYMBOL: rematerialization-recipes
SYMBOL: rematerialization-statistics
SYMBOL: rematerialization-observer

! A recipe is a location with no storage. Keep the original instruction
! identity so the optional value-flow verifier can preserve SSA provenance.
TUPLE: constant-recipe vreg val original-insn ;

: cheap-integer? ( obj -- ? )
    dup integer? [ -32768 32767 between? ] [ drop f ] if ;

: rematerialization-of ( vreg -- recipe/f )
    rematerialize-constants? get
    [ rematerialization-recipes get at ] [ drop f ] if ;

:: record-constant-definition ( insn definitions -- )
    insn defs-vregs [| vreg |
        vreg leader :> key
        key definitions key? [ f ] [
            insn ##load-integer? [
                insn val>> cheap-integer?
                vreg rep-of int-rep eq? and
                [ key insn val>> insn constant-recipe boa ] [ f ] if
            ] [ f ] if
        ] if key definitions set-at
    ] each ;

:: reject-rematerialization ( vregs definitions -- )
    vregs [ leader f swap definitions set-at ] each ;

:: reject-unsafe-constants ( insn definitions -- )
    ! A memory operand is an ABI requirement, not an allocator spill.
    insn clobber-insn? [
        insn uses-vregs definitions reject-rematerialization
    ] when
    ! Phi edge destinations can require memory-to-memory moves. Leave those
    ! values on the ordinary spilling path, including chordal SSA edges.
    insn ##phi? [
        insn uses-vregs definitions reject-rematerialization
    ] when
    insn uses-vregs [| vreg |
        vreg rep-of int-rep eq? [ ] [
            f vreg leader definitions set-at
        ] if
    ] each
    ! Integer representations can contain derived pointers. Never infer
    ! pointer safety from the representation alone.
    insn gc-map-insn? [
        insn gc-map>> :> map
        map gc-roots>> definitions reject-rematerialization
        map derived-roots>> [ keys ] [ values ] bi append
        definitions reject-rematerialization
    ] when ;

:: prepare-rematerialization ( cfg -- )
    f rematerialization-statistics set
    rematerialize-constants? get [
        H{ { "loads" 0 } } clone rematerialization-statistics set
        H{ } clone :> definitions
        cfg cfg>insns :> insns
        insns [ definitions record-constant-definition ] each
        insns [ definitions reject-unsafe-constants ] each
        definitions [ nip >boolean ] assoc-filter
    ] [ f ] if rematerialization-recipes set ;

: rematerialization-count ( -- n )
    rematerialization-statistics get "loads" of 0 or ;

:: emit-rematerialization ( recipe reg -- )
    reg recipe val>> ##load-integer new-insn :> insn
    rematerialization-observer get [
        recipe original-insn>> insn rot call( original insn -- )
    ] when*
    "loads" rematerialization-statistics get inc-at
    insn , ;
