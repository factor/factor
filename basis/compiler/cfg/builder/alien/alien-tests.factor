USING: accessors alien alien.c-types alien.strings alien.syntax assocs
classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params
compiler.cfg.builder.blocks compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks compiler.errors
compiler.test compiler.tree.builder compiler.tree.optimizer
cpu.architecture cpu.x86.assembler cpu.x86.assembler.operands
cpu.arm.64.assembler.registers kernel layouts literals locals make math namespaces
math.vectors.simd sequences stack-checker.alien system tools.test words ;
QUALIFIED-WITH: alien.c-types c
IN: compiler.cfg.builder.alien.tests

STRUCT: arm64-register-pair { x longlong } { y longlong } ;
STRUCT: arm64-hfa-pair { x c:float } { y c:float } ;
UNION-STRUCT: arm64-mixed-vector { v float-4 } { x int } ;
STRUCT: arm64-large-return { x longlong } { y longlong } { z longlong } ;

: next-flattened-parameter ( vreg tuple -- )
    [ first3 ] [ param-natural-size ] [ param-signed? ] tri
    next-parameter ;

: dummy-assembly ( -- ass )
    int { } cdecl [
        EAX 33 MOV
    ] alien-assembly ;

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

cpu arm.64? [
    ! Once both register banks are exhausted, a preceding eight-byte stack
    ! argument must not misalign a 128-bit SIMD argument.
    {
        V{
            { 8 int-rep 0 4 t }
            { 200 float-4-rep 16 16 f }
        }
    } [
        cdecl [
            9 <iota> [ int-rep f f 4 t next-parameter ] each
            8 <iota> [ 100 + float-rep f f 4 f next-parameter ] each
            200 float-4-rep f f 16 f next-parameter
        ] with-param-regs nip
    ] unit-test

    ! Standard AAPCS64 starts a 16-byte-aligned composite in an even-numbered
    ! X register. Apple's ABI explicitly permits an odd-numbered start.
    {
        $[ os macos? V{ 0 1 2 } V{ 0 2 3 } ? ]
    } [
        cdecl [
            0 int-rep f f 4 t next-parameter
            \ arm64-mixed-vector lookup-c-type flatten-parameter-type
            [| triple i |
                100 i + triple next-flattened-parameter
            ] each-index
        ] with-param-regs drop [ third n>> ] map
    ] unit-test

    ! Preserve the original composite alignment after flattening a mixed
    ! vector union into integer-sized chunks.
    {
        V{
            { 8 int-rep 0 4 t }
            { 100 int-rep 16 8 f }
            { 101 int-rep 24 8 f }
        }
    } [
        cdecl [
            9 <iota> [ int-rep f f 4 t next-parameter ] each
            \ arm64-mixed-vector lookup-c-type flatten-parameter-type
            [| triple i |
                100 i + triple next-flattened-parameter
            ] each-index
        ] with-param-regs nip
    ] unit-test

    ! Homogeneous aggregates also allocate atomically. When the final FP
    ! register cannot hold the whole pair, preserve its packed field offsets
    ! on the stack and exhaust the FP register bank for later arguments.
    {
        V{
            { 100 float-rep 0 4 f }
            { 101 float-rep 4 4 f }
            { 200 float-rep 8 4 f }
        }
    } [
        cdecl [
            7 <iota> [ double-rep f f 8 f next-parameter ] each
            \ arm64-hfa-pair lookup-c-type flatten-parameter-type
            [| triple i |
                100 i + triple next-flattened-parameter
            ] each-index
            200 float-rep f f 4 f next-parameter
        ] with-param-regs nip
    ] unit-test

    ! A composite cannot be split between the final argument register and the
    ! stack. Reject the two-register group atomically, then keep later integer
    ! arguments on the stack as required by AAPCS64.
    {
        V{
            { 100 int-rep 0 8 f }
            { 101 int-rep 8 8 f }
            { 200 int-rep 16 4 t }
        }
    } [
        cdecl [
            7 <iota> [ int-rep f f 4 t next-parameter ] each
            \ arm64-register-pair lookup-c-type flatten-parameter-type
            [| triple i |
                100 i + triple next-flattened-parameter
            ] each-index
            200 int-rep f f 4 t next-parameter
        ] with-param-regs nip
    ] unit-test
] when

! caller-parameters
cpu arm.64? [
    {
        V{ 8 0 }
        V{ }
    } [
        [
            \ arm64-large-return { int } cdecl f f "func"
            alien-invoke-params boa caller-parameters
            [ [ third n>> ] map , ] [ , ] bi*
        ] V{ } make rest first2
    ] cfg-unit-test
] when

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
        void { int c:float double char } cdecl f f "func"
        alien-invoke-params boa caller-parameters
    ] cfg-unit-test
] when

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
        { x86.64 [ { { 1 int-rep RAX } } { { 2 double-rep XMM0 } } ] }
        { arm.64 [ { ${ 1 int-rep X0 } } { ${ 2 double-rep V0 } } ] }
    } case
} [
    T{ alien-invoke-params { return int } } prepare-caller-return
    T{ alien-invoke-params { return double } } prepare-caller-return
] cfg-unit-test

! unbox-parameters

! unboxing ints is only needed on 32bit archs
cpu x86.32?
{
    { 2 4 }
    { { int-rep f f $[ cell ] f } { int-rep f f 4 t } }
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
    { { int-rep f f $[ cell ] f } { int-rep f f 4 t } }
    V{ T{ ##unbox-any-c-ptr { dst 2 } { src 1 } } }
} ? [
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
