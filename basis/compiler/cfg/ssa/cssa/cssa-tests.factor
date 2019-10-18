USING: accessors compiler.cfg compiler.cfg.instructions compiler.cfg.ssa.cssa
compiler.cfg.utilities kernel namespaces tools.test ;
IN: compiler.cfg.ssa.cssa.tests

! insert-phi-copies
{
    V{
        T{ ##phi
           { dst 103 }
           { inputs H{ { "bl1" 7 } { "bl2" 99 } } }
        }
        T{ ##parallel-copy { values V{ { 3 4 } } } }
    }
} [
    V{ { 3 4 } } phi-copies set
    V{
        T{ ##phi { dst 103 } { inputs H{ { "bl1" 7 } { "bl2" 99 } } } }
    } 0 insns>block
    [ insert-phi-copies ] keep instructions>>
] unit-test

! phi-copy-insn
{ T{ ##parallel-copy f V{ { 3 4 } } f } } [
    V{ { 3 4 } } phi-copy-insn
] unit-test
