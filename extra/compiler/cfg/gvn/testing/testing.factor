! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg compiler.cfg.alias-analysis
compiler.cfg.block-joining compiler.cfg.branch-splitting
compiler.cfg.copy-prop compiler.cfg.dce compiler.cfg.debugger
compiler.cfg.finalization compiler.cfg.graphviz
compiler.cfg.gvn compiler.cfg.gvn.graph compiler.cfg.height
compiler.cfg.ssa.construction compiler.cfg.tco
compiler.cfg.useless-conditionals fry io kernel math
math.private namespaces prettyprint sequences tools.annotations
;
IN: compiler.cfg.gvn.testing

SYMBOL: gvn-test

[ 0 100 [ 1 fixnum+fast ] times ]
test-builder first [
    optimize-tail-calls
    delete-useless-conditionals
    split-branches
    join-blocks
    normalize-height
    construct-ssa
    alias-analysis
] with-cfg gvn-test set-global

: watch-gvn ( -- )
    \ value-numbering-step
    [
        '[
            _ call
            "Basic block #" write basic-block get number>> .
            "vregs>gvns: "  write vregs>gvns  get .
            "vregs>vns: "   write vregs>vns   get .
            "exprs>vns: "   write exprs>vns   get .
            "vns>insns: "   write vns>insns   get .
            "\n---\n" print
        ]
    ] annotate ;

: reset-gvn ( -- )
    \ value-numbering-step reset ;

: test-gvn ( -- )
    watch-gvn
    gvn-test get-global [
        {
            value-numbering
            copy-propagation
            eliminate-dead-code
            finalize-cfg
        } [ watch-pass ] each-index drop
    ] with-cfg
    reset-gvn ;
