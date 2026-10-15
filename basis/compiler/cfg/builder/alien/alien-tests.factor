USING: accessors alien alien.c-types alien.strings arrays assocs classes.struct
combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien compiler.cfg.builder.alien.params
compiler.cfg.builder.blocks compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks compiler.errors
compiler.test compiler.tree.builder compiler.tree.optimizer compiler.units
continuations definitions
cpu.architecture cpu.x86.assembler cpu.x86.assembler.operands
cpu.arm.64.assembler.registers kernel layouts literals locals make namespaces
sequences stack-checker.alien system tools.test vocabs.loader words ;
IN: compiler.cfg.builder.alien.tests
QUALIFIED-WITH: cpu.riscv.64.assembler.registers rv
QUALIFIED-WITH: cpu.riscv.32.assembler.registers rv32
QUALIFIED-WITH: cpu.loongarch.64.assembler.registers la
QUALIFIED-WITH: cpu.mips.assembler.registers mi
QUALIFIED-WITH: cpu.s390x.assembler.registers z
QUALIFIED-WITH: cpu.alpha.64.assembler.registers al
QUALIFIED-WITH: cpu.arm.32.assembler ar
QUALIFIED-WITH: cpu.arm.32.compiler-assembler av
QUALIFIED-WITH: cpu.hppa.assembler.registers hp
QUALIFIED-WITH: cpu.m88k.assembler.registers m8

! During refresh, hats can re-enter the builder before it has generated a
! newly added instruction helper. Reproduce that state without an old image.
{ t } [
    [
        [
            "^^callback-stack" "compiler.cfg.hats" lookup-word forget
            "compiler.cfg.builder.alien" reload
        ] with-compilation-unit
        [ { 0 0 0 } emit-va-cursor-inputs ] V{ } make
        first ##callback-stack?
    ] [ "compiler.cfg.hats" reload ] finally
] cfg-unit-test

: dummy-assembly ( -- ass )
    int { } cdecl [
        int return-regs-for-type int-regs of first 33 %load-immediate
    ] alien-assembly ;

! Inline assembly must use the target ISA and its native result register.
! An x86 MOV leaves following fixed-width target instructions unaligned.
{ 33 } [ dummy-assembly ] unit-test

{ t } [
    <basic-block> dup set-basic-block dup
    \ dummy-assembly build-tree optimize-tree first
    [ emit-node ] V{ } make drop eq?
] cfg-unit-test

: dummy-callback ( -- cb )
    void { } cdecl [ ] alien-callback ;

{ 2 t } [
    \ dummy-callback build-tree optimize-tree gensym build-cfg
    [ length ] [ second frame-pointer?>> ] bi
] unit-test

{
    V{
        T{ ##load-reference { dst 1 } { obj t } }
        T{ ##load-integer { dst 2 } { val 3 } }
        T{ ##copy { dst 4 } { src 1 } { rep any-rep } }
        T{ ##copy { dst 3 } { src 2 } { rep any-rep } }
        T{ ##inc { loc D: 2 } }
        T{ ##branch }
    }
} [
    <basic-block> dup set-basic-block
    \ dummy-callback build-tree optimize-tree 3 swap nth child>>
    [ emit-callback-body drop ] V{ } make
] cfg-unit-test

! caller-linkage
${
    "malloc"
    os windows? "ucrtbase.dll" f ?
} [
    f f cdecl f "libc" "malloc" alien-invoke-params boa
    caller-linkage
    [ path>> alien>native-string ] ?call
] unit-test

SYMBOL: foo

{ t "fdkjlsdflfd" } [
    begin-stack-analysis \ foo f begin-cfg drop
    f f cdecl f f "fdkjlsdflfd" alien-invoke-params boa
    caller-linkage 2drop
    linkage-errors get foo of error>>
    [ no-such-symbol? ] [ name>> ] bi
] unit-test

! caller-parameters
cpu x86.64? [
    ${
        os windows? [
            V{
                { 1 int-rep RCX }
                { 2 float-rep XMM1 }
                { 3 double-rep XMM2 }
                { 4 int-rep R9 }
            }
        ] [
            V{
                { 1 int-rep RDI }
                { 2 float-rep XMM0 }
                { 3 double-rep XMM1 }
                { 4 int-rep RSI }
            }
        ] if
        V{ }
    } [
        void { int float double char } cdecl f f "func"
        alien-invoke-params boa caller-parameters
    ] cfg-unit-test
] when

! Targets without a dedicated result register prepend a hidden argument.
SINGLETON: ordinary-struct-result-cpu
M: ordinary-struct-result-cpu return-struct-in-registers? drop f ;
M: ordinary-struct-result-cpu struct-return-on-stack? f ;

STRUCT: indirect-result { a longlong } { b longlong } { c longlong } ;

{ { 1 42 } { { int-rep f f } { double-rep f f } } 1 } [
    ordinary-struct-result-cpu \ cpu [
        [
            { 42 } { { double-rep f f } } indirect-result
            prepare-struct-caller
        ] V{ } make drop
    ] with-variable
] cfg-unit-test

{ { 1 } { { int-rep f f } } 1 } [
    ordinary-struct-result-cpu \ cpu [
        [ { } { } indirect-result prepare-struct-caller ] V{ } make drop
    ] with-variable
] cfg-unit-test

! A fixed ABI result slot leaves normal argument positions untouched.
SINGLETON: fixed-stack-struct-result-cpu
M: fixed-stack-struct-result-cpu return-struct-in-registers? drop f ;
M: fixed-stack-struct-result-cpu struct-return-stack-offset -4 ;

{ { 42 } { { double-rep f f } } 1 { { 1 int-rep -4 } } 0 } [
    fixed-stack-struct-result-cpu \ cpu [
        V{ } clone stack-values set 0 stack-params set
        [ { 42 } { { double-rep f f } } indirect-result
          prepare-struct-caller ] V{ } make drop
        stack-values get [ first3 3array ] map >array stack-params get
    ] with-variable
] cfg-unit-test

{ 1 { { 1 int-rep -4 } } 0 } [
    fixed-stack-struct-result-cpu \ cpu [
        V{ } clone stack-values set 0 stack-params set
        indirect-result prepare-struct-callee
        stack-values get [ first3 3array ] map >array stack-params get
    ] with-variable
] cfg-unit-test

! caller-stack-cleanup
{ 0 } [
    alien-node-params new long >>return cdecl >>abi 25
    caller-stack-cleanup
] unit-test

! check-dlsym
{ } [
    "malloc" f check-dlsym
] unit-test

! prepare-caller-return
${
    cpu {
        { x86.32 [ { { 1 int-rep EAX } } { { 2 double-rep ST0 } } ] }
        { ppc.32 [ { { 1 int-rep 3 } } { { 2 double-rep 1 } } ] }
        { ppc.64 [ { { 1 int-rep 3 } } { { 2 double-rep 1 } } ] }
        { ppc.64le [ { { 1 int-rep 3 } } { { 2 double-rep 1 } } ] }
        { mips.32 [ { ${ 1 int-rep mi:V0 } } { ${ 2 double-rep mi:F0 } } ] }
        { mipsel.32 [ { ${ 1 int-rep mi:V0 } } { ${ 2 double-rep mi:F0 } } ] }
        { mips.64 [ { ${ 1 int-rep mi:V0 } } { ${ 2 double-rep mi:F0 } } ] }
        { mipsel.64 [ { ${ 1 int-rep mi:V0 } } { ${ 2 double-rep mi:F0 } } ] }
        { x86.64 [ { { 1 int-rep RAX } } { { 2 double-rep XMM0 } } ] }
        { arm.64 [ { ${ 1 int-rep X0 } } { ${ 2 double-rep V0 } } ] }
        { riscv.64 [ { ${ 1 int-rep rv:A0 } } { ${ 2 double-rep rv:FA0 } } ] }
        { loongarch.64 [ { ${ 1 int-rep la:A0 } } { ${ 2 double-rep la:FA0 } } ] }
        { riscv.32 [ { ${ 1 int-rep rv32:A0 } } { ${ 2 double-rep rv32:FA0 } } ] }
        { s390x [ { ${ 1 int-rep z:R2 } } { ${ 2 double-rep z:F0 } } ] }
        { alpha.64 [ { ${ 1 int-rep al:R0 } } { ${ 2 double-rep al:F0 } } ] }
        { arm.32 [
            { ${ 1 int-rep ar:R0 } }
            ! OpenBSD uses the base AAPCS double result in r0:r1.
            os openbsd?
            [ { ${ 2 int-rep ar:R0 } ${ 3 int-rep ar:R1 } } ]
            [ { ${ 2 double-rep av:S0 } } ] if
        ] }
        { sparc.32 [ { { 1 int-rep 8 } } { { 2 double-rep 0 } } ] }
        { sparc.64 [ { { 1 int-rep 8 } } { { 2 double-rep 0 } } ] }
        { hppa.32 [ { ${ 1 int-rep hp:R28 } } { ${ 2 double-rep hp:F4 } } ] }
        { m68k.32 [ { { 1 int-rep 0 } } { { 2 double-rep 0 } } ] }
        { m88k.32 [ { ${ 1 int-rep m8:R2 } } { ${ 2 double-rep m8:R2 } } ] }
        { vax.32 [ { { 1 int-rep 0 } } { { 2 double-rep 0 } } ] }
        { sh3.32 [ { { 1 int-rep 0 } } { { 2 double-rep 0 } } ] }
        { sh3be.32 [ { { 1 int-rep 0 } } { { 2 double-rep 0 } } ] }
        { sh4.32 [ { { 1 int-rep 0 } } { { 2 double-rep 0 } } ] }
        { sh4be.32 [ { { 1 int-rep 0 } } { { 2 double-rep 0 } } ] }
    } case
} [
    T{ alien-invoke-params { return int } } prepare-caller-return
    T{ alien-invoke-params { return double } } prepare-caller-return
] cfg-unit-test

! unbox-parameters

! MIPS and HPPA metadata records natural size and group alignment.
cpu mips? cpu hppa.32? or [
    cpu mips32? cpu hppa.32? or [
        {
            { 2 4 }
            { { int-rep f f 4 0 4 } { int-rep f f 4 0 4 } }
            V{
                T{ ##unbox-any-c-ptr { dst 2 } { src 1 } }
                T{ ##unbox { dst 4 } { src 3 } { unboxer "to_signed_4" } { rep int-rep } }
            }
        }
    ] [
        {
            { 2 4 }
            { { int-rep f f 8 0 8 } { int-rep f f 4 0 4 } }
            V{
                T{ ##unbox-any-c-ptr { dst 2 } { src 1 } }
                T{ ##convert-integer { dst 4 } { src 3 } { c-type $[ int base-type ] } }
            }
        }
    ] if
] [
! RV32 converts integer and pointer parameters to their full ABI width.
cpu riscv.32? [
    {
        { 3 6 }
        { { int-rep f f 4 } { int-rep f f 4 } }
        V{
            T{ ##unbox-any-c-ptr { dst 2 } { src 1 } }
            T{ ##convert-integer { dst 3 } { src 2 } { c-type $[ c-string base-type ] } }
            T{ ##unbox { dst 5 } { src 4 } { unboxer "to_signed_4" } { rep int-rep } }
            T{ ##convert-integer { dst 6 } { src 5 } { c-type $[ int base-type ] } }
        }
    }
] [ cpu riscv.64? cpu loongarch.64? or [
    {
        { 2 5 }
        { { int-rep f f $[ cell ] } { int-rep f f 4 } }
        V{
            T{ ##unbox-any-c-ptr { dst 2 } { src 1 } }
            T{ ##convert-integer { dst 4 } { src 3 } { c-type $[ int base-type ] } }
            T{ ##convert-integer { dst 5 } { src 4 } { c-type $[ int base-type ] } }
        }
    }
] [ cpu { x86.32 arm.32 ppc.32 sparc.32 } member? cpu sh? or
{
    { 2 4 }
    { { int-rep f f $[ cell ] } { int-rep f f 4 } }
    V{
        T{ ##unbox-any-c-ptr { dst 2 } { src 1 } }
        T{ ##unbox
           { dst 4 }
           { src 3 }
           { unboxer "to_signed_4" }
           { rep int-rep }
        }
    }
}
{
    { 2 3 }
    { { int-rep f f $[ cell ] } { int-rep f f 4 } }
    V{ T{ ##unbox-any-c-ptr { dst 2 } { src 1 } } }
} ? ] if ] if ] if [
    [ { c-string int } unbox-parameters ] V{ } make
] cfg-unit-test

! with-param-regs*
{
    V{ }
    V{ }
    f f
} [
    cdecl [ ] with-param-regs
    reg-values get stack-values get
] unit-test

USING: compiler.cfg.builder.alien.boxing math.floats.small.c-types math.vectors.simd ;
STRUCT: windows-vararg-pair { x double } { y double } ;
STRUCT: windows-vararg-hfa { x double } { y double } { z double } ;

: windows-vararg-layout ( types -- regs stack )
    '[
        t windows-arm64-varargs? [ _ unbox-parameters ] with-variable
        (caller-parameters)
    ] cdecl swap with-param-regs [ [ rest ] map ] bi@ ;

cpu arm.64? [
    { V{ { int-rep $[ X0 ] } { int-rep $[ X1 ] } { int-rep $[ X2 ] } { int-rep $[ X3 ] } } V{ } } [
        { float double half bfloat } windows-vararg-layout
    ] cfg-unit-test
    { V{ { int-rep $[ X0 ] } { int-rep $[ X1 ] } { int-rep $[ X2 ] } } V{ } } [
        { windows-vararg-pair windows-vararg-hfa } windows-vararg-layout
    ] cfg-unit-test
    { V{ { int-rep $[ X0 ] } { int-rep $[ X1 ] } { int-rep $[ X2 ] } { int-rep $[ X3 ] }
         { int-rep $[ X4 ] } { int-rep $[ X5 ] } { int-rep $[ X6 ] } { int-rep $[ X7 ] } }
      V{ { int-rep 0 8 } { int-rep 8 8 } } } [
        { int int int int int int int windows-vararg-pair double }
        windows-vararg-layout
    ] cfg-unit-test
    { V{ { int-rep $[ X0 ] } { int-rep $[ X1 ] } { int-rep $[ X2 ] } } V{ } } [
        { int float-4 } windows-vararg-layout
    ] cfg-unit-test
    { { { int-rep f f 8 } } { { int-rep f f 2 } } } [
        double base-type flatten-windows-vararg-type
        half base-type flatten-windows-vararg-type
    ] cfg-unit-test
] when

{ t 42 40 } [
    [ 42 8 emit-hppa-va-stack drop ] V{ } make first
    [ ##sub-imm? ] [ src1>> ] [ src2>> ] tri
] cfg-unit-test

! GNU MIPS uses positional FP slots in N64 and a mandatory O32 home area.
:: mips-scalar-layout ( types variadic? -- regs stack homes )
    cdecl [
        variadic? varargs-named-count set
        types [ base-type flatten-scalar-parameter ] map concat
        [ dup prepare-parameter-group
          0 swap [ first3 ] [ param-natural-size ] bi next-parameter ] each
    ] with-param-regs [ [ rest ] map ] bi@ stack-params get ;

cpu mips? [
    cpu mips32? [
        { V{ { int-rep $[ mi:A0 ] } { int-rep $[ mi:A2 ] } { int-rep $[ mi:A3 ] } }
          V{ { int-rep 16 4 } { int-rep 24 4 } { int-rep 28 4 } } 32 } [
            { int double int double } f mips-scalar-layout
        ] cfg-unit-test
        { V{ { double-rep $[ mi:F12 ] } { double-rep $[ mi:F14 ] } } V{ } 16 } [
            { double double } f mips-scalar-layout
        ] cfg-unit-test
        { V{ { int-rep $[ mi:A0 ] } { int-rep $[ mi:A2 ] } { int-rep $[ mi:A3 ] } }
          V{ { int-rep 16 4 } { int-rep 20 4 } } 24 } [
            { int double double } t mips-scalar-layout
        ] cfg-unit-test
    ] [
        { V{ { int-rep $[ mi:A0 ] } { double-rep $[ mi:F13 ] }
             { int-rep $[ mi:A2 ] } { double-rep $[ mi:F15 ] } } V{ } 0 } [
            { int double int double } f mips-scalar-layout
        ] cfg-unit-test
        { V{ { double-rep $[ mi:F12 ] } { double-rep $[ mi:F13 ] } } V{ } 0 } [
            { double double } f mips-scalar-layout
        ] cfg-unit-test
        { V{ { int-rep $[ mi:A0 ] } { int-rep $[ mi:A1 ] } { int-rep $[ mi:A2 ] } } V{ } 0 } [
            { int double double } t mips-scalar-layout
        ] cfg-unit-test
    ] if
] when
