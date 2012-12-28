! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel namespaces sequences math
arrays compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.liveness compiler.cfg.rpo
compiler.cfg.dominance compiler.cfg ;
IN: compiler.cfg.ssa.interference.live-ranges

! Live ranges for interference testing

<PRIVATE

SYMBOLS: local-def-indices local-kill-indices ;

: record-defs ( n insn -- )
    defs-vregs [ local-def-indices get set-at ] with each ;

: record-uses ( n insn -- )
    ! Record live intervals so that all but the first input interfere
    ! with the output. This lets us coalesce the output with the
    ! first input.
    dup uses-vregs [ 2drop ] [
        swap def-is-use-insn?
        [ [ first local-kill-indices get set-at ] [ rest-slice ] 2bi ] unless
        [ 1 + ] dip [ local-kill-indices get set-at ] with each
    ] if-empty ;

GENERIC: record-insn ( n insn -- )

M: ##phi record-insn
    record-defs ;

M: ##parallel-copy record-insn
    [ 2 * ] dip
    [ record-defs ]
    [ uses-vregs [ local-kill-indices get set-at ] with each ]
    2bi ;

M: vreg-insn record-insn
    [ 2 * ] dip [ record-defs ] [ record-uses ] 2bi ;

M: insn record-insn
    2drop ;

SYMBOLS: def-indices kill-indices ;

: compute-local-live-ranges ( insns -- )
    H{ } clone local-def-indices set
    H{ } clone local-kill-indices set
    [ swap record-insn ] each-index
    local-def-indices get basic-block get def-indices get set-at
    local-kill-indices get basic-block get kill-indices get set-at ;

PRIVATE>

: compute-live-ranges ( cfg -- )
    needs-dominance

    H{ } clone def-indices set
    H{ } clone kill-indices set
    [ compute-local-live-ranges ] simple-analysis ;

: def-index ( vreg bb -- n )
    def-indices get at at ;

ERROR: bad-kill-index vreg bb ;

: kill-index ( vreg bb -- n )
    2dup live-out? [ 2drop 1/0. ] [
        2dup kill-indices get at at* [ 2nip ] [
            drop 2dup live-in?
            [ bad-kill-index ] [ 2drop -1/0. ] if
        ] if
    ] if ;
