USING: accessors alien alien.c-types alien.strings assocs classes.struct
combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien compiler.cfg.builder.alien.params
compiler.cfg.builder.blocks compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks compiler.errors
compiler.test compiler.tree.builder compiler.tree.optimizer compiler.units
continuations definitions
cpu.architecture cpu.x86.assembler cpu.x86.assembler.operands
cpu.arm.64.assembler.registers kernel layouts literals make namespaces
sequences stack-checker.alien system tools.test vocabs.loader words ;
IN: compiler.cfg.builder.alien.tests

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
