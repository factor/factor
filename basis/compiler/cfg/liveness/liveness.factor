! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs sequences sets
compiler.cfg.def-use compiler.cfg.dataflow-analysis
compiler.cfg.instructions ;
IN: compiler.cfg.liveness

! See http://en.wikipedia.org/wiki/Liveness_analysis
! Do not run after SSA construction

BACKWARD-ANALYSIS: live

GENERIC: insn-liveness ( live-set insn -- )

: transfer-liveness ( live-set instructions -- live-set' )
    [ clone ] [ <reversed> ] bi* [
        [ dup ##phi? [ drop ] [ uses-vregs [ over conjoin ] each ] if ]
        [ defs-vregs [ over delete-at ] each ] bi
    ] each ;

: local-live-in ( instructions -- live-set )
    [ H{ } ] dip transfer-liveness keys ;

M: live-analysis transfer-set
    drop instructions>> transfer-liveness ;

M: live-analysis join-sets
    drop assoc-combine ;