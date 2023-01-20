! Copyright (C) 2009, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.def-use compiler.cfg.dominance
compiler.cfg.instructions compiler.cfg.liveness
compiler.cfg.parallel-copy compiler.cfg.rpo compiler.cfg.ssa.cssa
compiler.cfg.ssa.destruction.coalescing compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.interference.live-ranges compiler.cfg.utilities
kernel make sequences namespaces ;
IN: compiler.cfg.ssa.destruction

<PRIVATE

GENERIC: cleanup-insn ( insn -- )

: useful-copy? ( insn -- ? )
    [ dst>> ] [ src>> ] bi leaders = not ; inline

M: ##copy cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##parallel-copy cleanup-insn
    values>> [ leaders ] assoc-map [ first2 = ] reject
    parallel-copy-rep % ;

M: ##tagged>integer cleanup-insn
    dup useful-copy? [ , ] [ drop ] if ;

M: ##phi cleanup-insn drop ;

M: insn cleanup-insn , ;

: cleanup-cfg ( cfg -- )
    [ [ [ cleanup-insn ] each ] V{ } make ] simple-optimization ;

PRIVATE>

: destruct-ssa ( cfg -- )
    f leader-map set
    {
        needs-dominance
        construct-cssa
        compute-defs
        compute-insns
        compute-live-sets
        compute-live-ranges
        coalesce-cfg
        cleanup-cfg
        compute-live-sets
    } apply-passes ;
