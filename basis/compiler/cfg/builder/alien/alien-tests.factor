USING: accessors alien alien.c-types alien.strings arrays assocs
classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien compiler.cfg.builder.alien.params
compiler.cfg.builder.blocks compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks compiler.errors
compiler.test compiler.tree.builder compiler.tree.optimizer
cpu.architecture cpu.arm.64.assembler.registers cpu.x86.assembler
cpu.x86.assembler.operands kernel layouts literals make namespaces
sequences stack-checker.alien system tools.test words ;
IN: compiler.cfg.builder.alien.tests

STRUCT: macos-arm64-varargs-hfa
    { a float }
    { b float } ;

STRUCT: macos-arm64-varargs-three-ints
    { a int }
    { b int }
    { c int } ;

PACKED-STRUCT: macos-arm64-packed-five
    { c char }
    { i int } ;

STRUCT: macos-arm64-varargs-big-return
    { a long }
    { b long }
    { c long } ;

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

os macos? cpu arm.64? and [
    : register-id ( reg -- id )
        [ n>> ] [ width>> ] bi 2array ;

    : normalize-reg-param ( param -- param' )
        first3 [ name>> ] [ register-id ] bi* 3array ;

    : normalize-stack-param ( param -- param' )
        first4 [ name>> ] 2dip 4array ;

    : caller-parameter-shape ( params -- reg-inputs stack-inputs )
        init-cfg-test [
            caller-parameters
            [ [ normalize-reg-param ] map ]
            [ [ normalize-stack-param ] map ] bi*
        ] V{ } make drop ;

    {
        V{ { 3 "float-rep" { 0 128 } } { 4 "float-rep" { 1 128 } } }
        V{ { 5 "int-rep" 0 8 } }
    } [
        int { macos-arm64-varargs-hfa int } cdecl 1 f "func"
        alien-invoke-params boa caller-parameter-shape
    ] unit-test

    {
        V{ { 3 "int-rep" { 0 64 } } { 4 "int-rep" { 1 64 } } }
        V{ { 5 "int-rep" 0 8 } }
    } [
        int { macos-arm64-varargs-three-ints int } cdecl 1 f "func"
        alien-invoke-params boa caller-parameter-shape
    ] unit-test

    {
        V{
            { 1 "int-rep" { 0 64 } } { 2 "int-rep" { 1 64 } }
            { 3 "int-rep" { 2 64 } } { 4 "int-rep" { 3 64 } }
            { 5 "int-rep" { 4 64 } } { 6 "int-rep" { 5 64 } }
            { 7 "int-rep" { 6 64 } } { 8 "int-rep" { 7 64 } }
        }
        V{
            { 9 "int-rep" 0 1 }
            { 10 "int-rep" 2 2 }
            { 11 "int-rep" 8 8 }
        }
    } [
        int { int int int int int int int int char short int }
        cdecl 10 f "func" alien-invoke-params boa caller-parameter-shape
    ] unit-test

    {
        V{
            { 12 "int-rep" { 0 64 } } { 1 "int-rep" { 1 64 } }
            { 2 "int-rep" { 2 64 } } { 3 "int-rep" { 3 64 } }
            { 4 "int-rep" { 4 64 } } { 5 "int-rep" { 5 64 } }
            { 6 "int-rep" { 6 64 } } { 7 "int-rep" { 7 64 } }
        }
        V{
            { 8 "int-rep" 0 4 }
            { 9 "int-rep" 4 1 }
            { 10 "int-rep" 6 2 }
            { 11 "int-rep" 8 8 }
        }
    } [
        macos-arm64-varargs-big-return
        { int int int int int int int int char short int }
        cdecl 10 f "func" alien-invoke-params boa caller-parameter-shape
    ] unit-test

    {
        V{
            { 1 "int-rep" { 0 64 } } { 2 "int-rep" { 1 64 } }
            { 3 "int-rep" { 2 64 } } { 4 "int-rep" { 3 64 } }
            { 5 "int-rep" { 4 64 } } { 6 "int-rep" { 5 64 } }
            { 7 "int-rep" { 6 64 } } { 8 "int-rep" { 7 64 } }
        }
        V{
            { 11 "int-rep" 0 8 }
            { 12 "int-rep" 8 1 }
        }
    } [
        int { int int int int int int int int macos-arm64-packed-five char }
        cdecl f f "func" alien-invoke-params boa caller-parameter-shape
    ] unit-test

    {
        V{
            { 1 "int-rep" { 0 64 } } { 2 "int-rep" { 1 64 } }
            { 3 "int-rep" { 2 64 } } { 4 "int-rep" { 3 64 } }
            { 5 "int-rep" { 4 64 } } { 6 "int-rep" { 5 64 } }
            { 7 "int-rep" { 6 64 } } { 8 "int-rep" { 7 64 } }
        }
        V{
            { 9 "int-rep" 0 1 }
            { 12 "int-rep" 8 8 }
            { 13 "int-rep" 16 1 }
        }
    } [
        int { int int int int int int int int char macos-arm64-packed-five char }
        cdecl f f "func" alien-invoke-params boa caller-parameter-shape
    ] unit-test
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
