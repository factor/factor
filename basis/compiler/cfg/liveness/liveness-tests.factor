USING: compiler.cfg compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.liveness accessors tools.test cpu.architecture ;
IN: compiler.cfg.liveness.tests

[
    H{
        { "A" H{ { V int-regs 1 V int-regs 1 } { V int-regs 4 V int-regs 4 } } }
        { "B" H{ { V int-regs 3 V int-regs 3 } { V int-regs 2 V int-regs 2 } } }
    }
] [
    <basic-block> V{
        T{ ##phi f V int-regs 0 { { "A" V int-regs 1 } { "B" V int-regs 2 } } }
        T{ ##phi f V int-regs 1 { { "B" V int-regs 3 } { "A" V int-regs 4 } } }
    } >>instructions compute-phi-live-in
] unit-test