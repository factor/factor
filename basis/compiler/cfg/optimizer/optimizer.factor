! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences compiler.cfg.rpo
compiler.cfg.instructions
compiler.cfg.predecessors
compiler.cfg.useless-blocks
compiler.cfg.height
compiler.cfg.alias-analysis
compiler.cfg.value-numbering
compiler.cfg.dead-code
compiler.cfg.write-barrier ;
IN: compiler.cfg.optimizer

: trivial? ( insns -- ? )
    dup length 2 = [ first ##call? ] [ drop f ] if ;

: optimize-cfg ( cfg -- cfg' )
    compute-predecessors
    delete-useless-blocks
    delete-useless-conditionals
    [
        dup trivial? [
            normalize-height
            alias-analysis
            value-numbering
            eliminate-dead-code
            eliminate-write-barriers
        ] unless
    ] change-basic-blocks ;
