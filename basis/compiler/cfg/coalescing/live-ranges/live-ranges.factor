! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel namespaces sequences
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.liveness compiler.cfg.rpo ;
IN: compiler.cfg.coalescing.live-ranges

! Live ranges for interference testing

<PRIVATE

SYMBOLS: local-def-indices local-kill-indices ;

: record-defs ( n vregs -- )
    local-def-indices get '[ _ set-at ] with each ;

: record-uses ( n vregs -- )
    local-kill-indices get '[ _ set-at ] with each ;

: visit-insn ( insn n -- )
    [ swap defs-vregs record-defs ]
    [ swap uses-vregs record-uses ]
    [ over def-is-use-insn? [ swap defs-vregs record-uses ] [ 2drop ] if ]
    2tri ;

SYMBOLS: def-indices kill-indices ;

: compute-local-live-ranges ( bb -- )
    H{ } clone local-def-indices set
    H{ } clone local-kill-indices set
    instructions>> [ visit-insn ] each-index ;

PRIVATE>

: compute-live-ranges ( cfg -- )
    [ compute-local-live-ranges ] each-basic-block ;

: def-index ( vreg bb -- n )
    def-indices get at at ;

: kill-index ( vreg bb -- n )
    2dup live-out key? [ 2drop 1/0. ] [ kill-indices get at at ] if ;
