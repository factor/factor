USING: combinators.extras compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state kernel namespaces tools.test ;
IN: compiler.cfg.linear-scan.allocation.state.tests

{
    T{ spill-slot f 0 }
    T{ spill-slot f 8 }
    T{ cfg { spill-area-size 16 } }
} [
    H{ } clone spill-slots set
    T{ cfg { spill-area-size 0 } } cfg set
    [ 8 next-spill-slot ] twice
    cfg get
] unit-test
