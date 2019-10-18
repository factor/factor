IN: cpu.x86.tests
USING: cpu.x86.features tools.test math.libm kernel.private math
compiler.cfg.instructions compiler.cfg.debugger kernel ;

[ ] [
    [ { float } declare fsqrt ]
    [ ##sqrt? ] contains-insn?
    sse2?
    assert=
] unit-test
