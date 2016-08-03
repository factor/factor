! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple compiler.cfg
compiler.cfg.builder compiler.cfg.def-use
compiler.cfg.finalization compiler.cfg.gc-checks
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.optimizer compiler.cfg.registers
compiler.cfg.representations
compiler.cfg.representations.preferred compiler.cfg.rpo
compiler.cfg.save-contexts
compiler.cfg.utilities compiler.tree.builder
compiler.tree.optimizer compiler.units fry hashtables io kernel math
namespaces prettyprint prettyprint.backend prettyprint.custom
prettyprint.sections quotations random sequences vectors words strings ;
FROM: compiler.cfg.linearization => number-blocks ;
IN: compiler.cfg.debugger

GENERIC: test-builder ( quot -- cfgs )

: build-optimized-tree ( callable/word -- tree )
    reset-vreg-counter
    build-tree optimize-tree ;

M: callable test-builder
    build-optimized-tree gensym build-cfg ;

M: word test-builder
    [ build-optimized-tree ] keep build-cfg ;

: run-passes ( cfgs passes -- cfgs' )
    '[ dup cfg set dup _ apply-passes ] map ; inline

: test-ssa ( quot -- cfgs )
    test-builder { optimize-cfg } run-passes ;

: test-flat ( quot -- cfgs )
    test-builder {
        optimize-cfg
        select-representations
        insert-gc-checks
        insert-save-contexts
    } run-passes ;

: test-regs ( quot -- cfgs )
    test-builder { optimize-cfg finalize-cfg } run-passes ;

GENERIC: insn. ( insn -- )

M: ##phi insn.
    clone [ [ [ number>> ] dip ] assoc-map ] change-inputs
    call-next-method ;

! XXX: pprint on a string prints the double quotes.
! This will cause graphviz to choke, so print without quotes.
M: insn insn. tuple>array but-last [
        bl
    ] [
        dup string? [ print ] [ pprint ] if
    ] interleave nl ;

: block. ( bb -- )
    "=== Basic block #" write dup number>> . nl
    dup instructions>> [ insn. ] each nl
    successors>> [
        "Successors: " write
        [ number>> unparse ] map ", " join print nl
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

: ssa. ( quot/word -- ) test-ssa cfgs. ;
: flat. ( quot/word -- ) test-flat cfgs. ;
: regs. ( quot/word -- ) test-regs cfgs. ;

! Prettyprinting
: pprint-loc ( loc word -- ) <block pprint-word n>> pprint* block> ;

M: ds-loc pprint* \ D: pprint-loc ;

M: rs-loc pprint* \ R: pprint-loc ;

: resolve-phis ( bb -- )
    [
        [ [ [ get ] dip ] assoc-map ] change-inputs drop
    ] each-phi ;

: test-bb ( insns n -- )
    [ insns>block dup ] keep set resolve-phis ;

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
            [ [ defs-vregs ] [ defs-vreg-reps ] bi zip ]
            bi append
        ] map concat
    ] map concat >hashtable representations set ;

: count-insns ( quot insn-check -- ? )
    [ test-regs [ cfg>insns ] map concat ] dip count ; inline

: contains-insn? ( quot insn-check -- ? )
    count-insns 0 > ; inline
