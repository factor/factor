IN: cpu.x86.tests
USING: compiler.cfg.debugger compiler.cfg.instructions
compiler.codegen.gc-maps compiler.codegen.relocation cpu.architecture
cpu.x86.features kernel kernel.private make math math.libm namespaces sequences
tools.test ;

{ } [
    [ { float } declare fsqrt ]
    [ ##sqrt? ] contains-insn?
    sse2?
    assert=
] unit-test

! %call-gc
{ V{ } } [
    init-relocation init-gc-maps
    [ T{ gc-map { scrub-d V{ } } } %call-gc ] B{ } make drop
    gc-maps get
] unit-test

{ 1 } [
    init-relocation init-gc-maps
    [ T{ gc-map { scrub-d V{ 0 0 } } } %call-gc ] B{ } make drop
    gc-maps get length
] unit-test

! %alien-invoke
{ 1 } [
    init-relocation init-gc-maps [
        { } { } { } { } 0 0 { } "dll" T{ gc-map { scrub-d V{ 0 } } } %alien-invoke
    ] B{ } make drop
    gc-maps get length
] unit-test
