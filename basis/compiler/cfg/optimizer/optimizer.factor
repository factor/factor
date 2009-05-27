! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors combinators namespaces
compiler.cfg.predecessors
compiler.cfg.useless-blocks
compiler.cfg.height
compiler.cfg.stack-analysis
compiler.cfg.alias-analysis
compiler.cfg.value-numbering
compiler.cfg.dce
compiler.cfg.write-barrier
compiler.cfg.liveness
compiler.cfg.rpo
compiler.cfg.phi-elimination ;
IN: compiler.cfg.optimizer

: optimize-cfg ( cfg -- cfg )
    [
        [
            [ compute-predecessors ]
            [ delete-useless-blocks ]
            [ delete-useless-conditionals ] tri
        ] [
            reverse-post-order
            {
                [ normalize-height ]
                [ stack-analysis ]
                [ compute-liveness ]
                [ alias-analysis ]
                [ value-numbering ]
                [ eliminate-dead-code ]
                [ eliminate-write-barriers ]
                [ eliminate-phis ]
            } cleave
        ] [ ] tri
    ] with-scope ;
