! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.builder compiler.cfg.linear-scan
compiler.cfg.liveness compiler.cfg.mr compiler.cfg.optimizer
compiler.cfg.stacks.finalize compiler.cfg.stacks.global
compiler.codegen compiler.tree.builder compiler.tree.optimizer
kernel make sequences tools.annotations tools.crossref ;
IN: bootstrap.compiler.timing

: passes ( word -- seq )
    def>> uses [ vocabulary>> "compiler." head? ] filter ;

: high-level-passes ( -- seq ) \ optimize-tree passes ;

: low-level-passes ( -- seq ) \ optimize-cfg passes ;

: machine-passes ( -- seq ) \ build-mr passes ;

: linear-scan-passes ( -- seq ) \ (linear-scan) passes ;

: all-passes ( -- seq )
    [
        \ build-tree ,
        \ optimize-tree ,
        high-level-passes %
        \ build-cfg ,
        \ compute-global-sets ,
        \ finalize-stack-shuffling ,
        \ optimize-cfg ,
        low-level-passes %
        \ compute-live-sets ,
        \ build-mr ,
        machine-passes %
        linear-scan-passes %
        \ generate ,
    ] { } make ;

all-passes [ [ reset ] [ add-timing ] bi ] each