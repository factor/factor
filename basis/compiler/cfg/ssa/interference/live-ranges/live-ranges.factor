! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel namespaces sequences math
arrays compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.liveness.ssa compiler.cfg.rpo compiler.cfg.dominance ;
IN: compiler.cfg.ssa.interference.live-ranges

! Live ranges for interference testing

<PRIVATE

SYMBOLS: local-def-indices local-kill-indices ;

: record-def ( n insn -- )
    ! We allow multiple defs of a vreg as long as they're
    ! all in the same basic block
    defs-vreg dup [
        local-def-indices get 2dup key?
        [ 3drop ] [ set-at ] if
    ] [ 2drop ] if ;

: record-uses ( n insn -- )
    ! Record live intervals so that all but the first input interfere
    ! with the output. This lets us coalesce the output with the
    ! first input.
    [ uses-vregs ] [ def-is-use-insn? ] bi over empty? [ 3drop ] [
        [ [ first local-kill-indices get set-at ] [ rest-slice ] 2bi ] unless
        [ 1 + ] dip [ local-kill-indices get set-at ] with each
    ] if ;

: visit-insn ( insn n -- )
    2 * swap [ record-def ] [ record-uses ] 2bi ;

SYMBOLS: def-indices kill-indices ;

: compute-local-live-ranges ( bb -- )
    H{ } clone local-def-indices set
    H{ } clone local-kill-indices set
    [ instructions>> [ visit-insn ] each-index ]
    [ [ local-def-indices get ] dip def-indices get set-at ]
    [ [ local-kill-indices get ] dip kill-indices get set-at ]
    tri ;

PRIVATE>

: compute-live-ranges ( cfg -- )
    needs-dominance

    H{ } clone def-indices set
    H{ } clone kill-indices set
    [ compute-local-live-ranges ] each-basic-block ;

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
