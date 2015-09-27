USING: compiler.cfg.debugger compiler.cfg.instructions
compiler.cfg.registers compiler.codegen.gc-maps
compiler.codegen.relocation cpu.architecture cpu.x86 cpu.x86.assembler
cpu.x86.features kernel kernel.private layouts make math math.libm
namespaces sequences system tools.test ;
IN: cpu.x86.tests

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

! %clear
{ t } [
    [ D: 0 %clear ] B{ } make
    cpu x86.32? B{ 199 6 144 18 0 0 } B{ 73 199 6 144 18 0 0 } ? =
] unit-test

! %prologue
{ t } [
    [ 2 cells %prologue ] B{ } make
    [ pic-tail-reg PUSH ] B{ } make =
] unit-test

{ t } [
    [ 8 cells %prologue ] B{ } make
    [ stack-reg 7 cells SUB ] B{ } make =
] unit-test
