USING: compiler.cfg.instructions compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.live-intervals cpu.x86.assembler.operands make
tools.test ;
IN: compiler.cfg.linear-scan.assignment.tests

{ { T{ ##spill { src RAX } } } } [
    [
        T{ live-interval-state { vreg 1234 } { reg RAX } } insert-spill
    ] { } make
] unit-test
