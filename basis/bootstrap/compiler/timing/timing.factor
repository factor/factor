! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel make sequences tools.annotations tools.crossref ;
QUALIFIED: compiler.cfg.builder
QUALIFIED: compiler.cfg.linear-scan
QUALIFIED: compiler.cfg.optimizer
QUALIFIED: compiler.cfg.finalization
QUALIFIED: compiler.codegen
QUALIFIED: compiler.tree.builder
QUALIFIED: compiler.tree.optimizer
QUALIFIED: compiler.cfg.liveness
QUALIFIED: compiler.cfg.liveness.ssa
IN: bootstrap.compiler.timing

: passes ( word -- seq )
    def>> uses [ vocabulary>> "compiler." head? ] filter ;

: high-level-passes ( -- seq ) \ compiler.tree.optimizer:optimize-tree passes ;

: low-level-passes ( -- seq ) \ compiler.cfg.optimizer:optimize-cfg passes ;

: machine-passes ( -- seq ) \ compiler.cfg.finalization:finalize-cfg passes ;

: linear-scan-passes ( -- seq ) \ compiler.cfg.linear-scan:linear-scan passes ;

: all-passes ( -- seq )
    [
        \ compiler.tree.builder:build-tree ,
        \ compiler.tree.optimizer:optimize-tree ,
        high-level-passes %
        \ compiler.cfg.builder:build-cfg ,
        \ compiler.cfg.optimizer:optimize-cfg ,
        low-level-passes %
        \ compiler.cfg.finalization:finalize-cfg ,
        machine-passes %
        linear-scan-passes %
        \ compiler.codegen:generate ,
        \ compiler.cfg.liveness:compute-live-sets ,
        \ compiler.cfg.liveness.ssa:compute-ssa-live-sets ,
    ] { } make ;

all-passes [ [ reset ] [ add-timing ] bi ] each
