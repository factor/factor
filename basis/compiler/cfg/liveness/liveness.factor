! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs sequences sets
compiler.cfg.def-use compiler.cfg.dataflow-analysis
compiler.cfg.instructions ;
IN: compiler.cfg.liveness

! See http://en.wikipedia.org/wiki/Liveness_analysis
! Do not run after SSA construction

BACKWARD-ANALYSIS: live

: transfer-liveness ( live-set instructions -- live-set' )
    [ clone ] [ <reversed> ] bi* [
        [ uses-vregs [ over conjoin ] each ]
        [ defs-vregs [ over delete-at ] each ] bi
    ] each ;

: local-live-in ( instructions -- live-set )
    [ ##phi? not ] filter [ H{ } ] dip transfer-liveness keys ;

M: live-analysis transfer-set
    drop instructions>> transfer-liveness ;

M: live-analysis join-sets
    drop assoc-combine ;