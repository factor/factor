! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel make sequences tools.annotations tools.crossref ;
QUALIFIED: compiler.cfg.builder
QUALIFIED: compiler.cfg.linear-scan
QUALIFIED: compiler.cfg.mr
QUALIFIED: compiler.cfg.optimizer
QUALIFIED: compiler.cfg.stacks.finalize
QUALIFIED: compiler.cfg.stacks.global
QUALIFIED: compiler.codegen
QUALIFIED: compiler.tree.builder
QUALIFIED: compiler.tree.optimizer
IN: bootstrap.compiler.timing

: passes ( word -- seq )
    def>> uses [ vocabulary>> "compiler." head? ] filter ;

: high-level-passes ( -- seq ) \ compiler.tree.optimizer:optimize-tree passes ;

: low-level-passes ( -- seq ) \ compiler.cfg.optimizer:optimize-cfg passes ;

: machine-passes ( -- seq ) \ compiler.cfg.mr:build-mr passes ;

: linear-scan-passes ( -- seq ) \ compiler.cfg.linear-scan:(linear-scan) passes ;

: all-passes ( -- seq )
    [
        \ compiler.tree.builder:build-tree ,
        \ compiler.tree.optimizer:optimize-tree ,
        high-level-passes %
        \ compiler.cfg.builder:build-cfg ,
        \ compiler.cfg.stacks.global:compute-global-sets ,
        \ compiler.cfg.stacks.finalize:finalize-stack-shuffling ,
        \ compiler.cfg.optimizer:optimize-cfg ,
        low-level-passes %
        \ compiler.cfg.mr:build-mr ,
        machine-passes %
        linear-scan-passes %
        \ compiler.codegen:generate ,
    ] { } make ;

all-passes [ [ reset ] [ add-timing ] bi ] each