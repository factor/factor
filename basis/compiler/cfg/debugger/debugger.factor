! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words sequences quotations namespaces io vectors
arrays hashtables classes.tuple accessors prettyprint
prettyprint.config assocs prettyprint.backend prettyprint.custom
prettyprint.sections parser compiler.tree.builder
compiler.tree.optimizer cpu.architecture compiler.cfg.builder
compiler.cfg.linearization compiler.cfg.registers
compiler.cfg.stack-frame compiler.cfg.linear-scan
compiler.cfg.optimizer compiler.cfg.finalization
compiler.cfg.instructions compiler.cfg.utilities
compiler.cfg.def-use compiler.cfg.rpo
compiler.cfg.representations compiler.cfg.gc-checks
compiler.cfg.save-contexts compiler.cfg
compiler.cfg.representations.preferred ;
FROM: compiler.cfg.linearization => number-blocks ;
IN: compiler.cfg.debugger

GENERIC: test-builder ( quot -- cfgs )

M: callable test-builder
    0 vreg-counter set-global
    build-tree optimize-tree gensym build-cfg ;

M: word test-builder
    0 vreg-counter set-global
    [ build-tree optimize-tree ] keep build-cfg ;

: test-optimizer ( quot -- cfgs )
    test-builder [ [ optimize-cfg ] with-cfg ] map ;

: test-ssa ( quot -- cfgs )
    test-builder [
        [
            optimize-cfg
        ] with-cfg
    ] map ;

: test-flat ( quot -- cfgs )
    test-builder [
        [
            optimize-cfg
            select-representations
            insert-gc-checks
            insert-save-contexts
        ] with-cfg
    ] map ;

: test-regs ( quot -- cfgs )
    test-builder [
        [
            optimize-cfg
            finalize-cfg
        ] with-cfg
    ] map ;

GENERIC: insn. ( insn -- )

M: ##phi insn.
    clone [ [ [ number>> ] dip ] assoc-map ] change-inputs
    call-next-method ;

M: insn insn. tuple>array but-last [ bl ] [ pprint ] interleave nl ;

: block. ( bb -- )
    "=== Basic block #" write dup block-number . nl
    dup instructions>> [ insn. ] each nl
    successors>> [
        "Successors: " write
        [ block-number unparse ] map ", " join print nl
    ] unless-empty ;

: cfg. ( cfg -- )
    [
        dup linearization-order number-blocks
        "=== word: " write
        dup word>> pprint
        ", label: " write
        dup label>> pprint nl nl
        dup linearization-order [ block. ] each
        "=== stack frame: " write
        stack-frame>> .
    ] with-scope ;

: cfgs. ( cfgs -- )
    [ nl ] [ cfg. ] interleave ;

: ssa. ( quot -- ) test-ssa cfgs. ;
: flat. ( quot -- ) test-flat cfgs. ;
: regs. ( quot -- ) test-regs cfgs. ;

! Prettyprinting
: pprint-loc ( loc word -- ) <block pprint-word n>> pprint* block> ;

M: ds-loc pprint* \ D pprint-loc ;

M: rs-loc pprint* \ R pprint-loc ;

: resolve-phis ( bb -- )
    [
        [ [ [ get ] dip ] assoc-map ] change-inputs drop
    ] each-phi ;

: test-bb ( insns n -- )
    [ <basic-block> swap >>number swap >>instructions dup ] keep set
    resolve-phis ;

: edge ( from to -- )
    [ get ] bi@ 1vector >>successors drop ;

: edges ( from tos -- )
    [ get ] [ [ get ] V{ } map-as ] bi* >>successors drop ;

: test-diamond ( -- )
    0 1 edge
    1 { 2 3 } edges
    2 4 edge
    3 4 edge ;

: fake-representations ( cfg -- )
    post-order [
        instructions>> [
            [ [ temp-vregs ] [ temp-vreg-reps ] bi zip ]
            [ [ defs-vreg ] [ defs-vreg-rep ] bi 2dup and [ 2array ] [ 2drop f ] if ]
            bi [ suffix ] when*
        ] map concat
    ] map concat >hashtable representations set ;
