! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple compiler.cfg
compiler.cfg.builder compiler.cfg.finalization
compiler.cfg.gc-checks compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.optimizer
compiler.cfg.registers compiler.cfg.representations
compiler.cfg.save-contexts compiler.cfg.utilities
compiler.tree.builder compiler.tree.optimizer formatting io
kernel math namespaces prettyprint quotations sequences
splitting strings words ;
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
: insn-number. ( n -- )
    dup integer? [ "%4d " printf ] [ drop "     " printf ] if ;

M: insn insn. ( insn -- )
    pack-tuple unclip-last insn-number. [
        dup string? [ unparse ] unless
    ] map join-words print ;

: block-header. ( bb -- )
    [ number>> ] [ kill-block?>> "(k)" "" ? ] bi
    "=== Basic block #%d %s\n\n" printf ;

: instructions. ( bb -- )
    instructions>> [ insn. ] each nl ;

: successors. ( bb -- )
    successors>> [
        [ number>> unparse ] map ", " join
        "Successors: %s\n\n" printf
    ] unless-empty ;

: block. ( bb -- )
    [ block-header. ] [ instructions. ] [ successors. ] tri ;

: cfg-header. ( cfg -- )
    [ word>> ] [ label>> ] bi "=== word: %u, label: %u\n\n" printf ;

: blocks. ( cfg -- )
    linearization-order [ block. ] each ;

: stack-frame. ( cfg -- )
    stack-frame>> "=== stack frame: %u\n" printf ;

: cfg. ( cfg -- )
    dup linearization-order number-blocks [
        [ cfg-header. ] [ blocks. ] [ stack-frame. ] tri
    ] with-scope ;

: cfgs. ( cfgs -- )
    [ nl ] [ cfg. ] interleave ;

: ssa. ( quot/word -- ) test-ssa cfgs. ;
: flat. ( quot/word -- ) test-flat cfgs. ;
: regs. ( quot/word -- ) test-regs cfgs. ;
