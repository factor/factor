! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel namespaces sequences math
arrays compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.liveness.ssa compiler.cfg.rpo ;
IN: compiler.cfg.ssa.interference.live-ranges

! Live ranges for interference testing

<PRIVATE

SYMBOLS: local-def-indices local-kill-indices ;

: record-def ( n vregs -- )
    dup [ local-def-indices get set-at ] [ 2drop ] if ;

: record-uses ( n vregs -- )
    local-kill-indices get '[ _ set-at ] with each ;

: visit-insn ( insn n -- )
    ! Instructions are numbered 2 apart. If the instruction requires
    ! that outputs are in different registers than the inputs, then
    ! a use will be registered for every output immediately after
    ! this instruction and before the next one, ensuring that outputs
    ! interfere with inputs.
    2 *
    [ swap defs-vreg record-def ]
    [ swap uses-vregs record-uses ]
    [ over def-is-use-insn? [ 1 + swap defs-vreg 1array record-uses ] [ 2drop ] if ]
    2tri ;

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
