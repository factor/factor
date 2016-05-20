USING: compiler.cfg.debugger compiler.cfg.instructions
compiler.cfg.registers compiler.codegen.gc-maps
compiler.codegen.relocation cpu.architecture cpu.x86 cpu.x86.assembler
cpu.x86.assembler.operands cpu.x86.features kernel kernel.private
layouts make math math.libm namespaces sequences system tools.test ;
IN: cpu.x86.tests

{ } [
    [ { float } declare fsqrt ]
    [ ##sqrt? ] contains-insn?
    sse2?
    assert=
] unit-test

! (%compare-tagged)
cpu x86.64? [
    {
        B{ 72 129 248 255 255 255 255 }
    } [
        init-relocation [ RAX RAX (%compare-tagged) ] B{ } make
    ] unit-test
] when

! %add-imm
{
    B{ 72 255 192 }
    B{ 72 131 192 29 }
} [
    [ RAX RAX 1 %add-imm ] B{ } make
    [ RAX RAX 29 %add-imm ] B{ } make
] unit-test

! %and-imm
{
    B{ 131 225 6 }
} [
    [ RCX RCX 0x6 %and-imm ] B{ } make
] unit-test

! %alien-invoke
{ 1 } [
    init-relocation init-gc-maps [
        { } { } { } { } 0 0 { } "dll" T{ gc-map { scrub-d V{ 0 } } } %alien-invoke
    ] B{ } make drop
    gc-maps get length
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

! %clear
{ t } [
    [ D: 0 %clear ] B{ } make
    cpu x86.32? B{ 199 6 144 18 0 0 } B{ 73 199 6 144 18 0 0 } ? =
] unit-test

! %dispatch
cpu x86.64? [
    {
        B{ 72 187 0 0 0 0 0 0 0 0 72 255 100 3 6 0 }
    }
    [
        init-relocation [ RAX RBX %dispatch ] B{ } make
    ] unit-test
] when

! %load-immediate
{ B{ 49 201 } } [
    [ RCX 0 %load-immediate ] B{ } make
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

!  %replace-imm
cpu x86.64? [
    {
        B{ 73 199 6 0 0 0 0 }
    }
    [
        init-relocation [ 34.0 D: 0 %replace-imm ] B{ } make
    ] unit-test
] when
