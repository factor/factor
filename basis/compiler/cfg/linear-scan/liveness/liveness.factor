! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs compiler.cfg.def-use
compiler.cfg.dataflow-analysis ;
IN: compiler.cfg.linear-scan.liveness

! See http://en.wikipedia.org/wiki/Liveness_analysis

BACKWARD-ANALYSIS: live

M: live-analysis transfer-set
    drop instructions>>
    [ gen-set assoc-union ] keep
    kill-set assoc-diff ;

M: live-analysis join-sets
    drop assoc-combine ;