USING: compiler.cfg.dead-code compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger
cpu.architecture tools.test ;
IN: compiler.cfg.dead-code.tests

[ { } ] [
    { T{ ##load-immediate f V int-regs 134 16 } }
    eliminate-dead-code
] unit-test
