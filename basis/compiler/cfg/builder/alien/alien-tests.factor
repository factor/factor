USING: accessors alien alien.c-types alien.strings assocs compiler.cfg
compiler.cfg.builder compiler.cfg.builder.alien
compiler.cfg.builder.alien.params compiler.cfg.builder.blocks
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stacks
compiler.errors compiler.test compiler.tree.builder
compiler.tree.optimizer cpu.architecture cpu.x86.assembler
cpu.x86.assembler.operands kernel literals make namespaces sequences
stack-checker.alien system tools.test words ;
IN: compiler.cfg.builder.alien.tests

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
    cpu x86.32? { { 1 int-rep EAX } } { { 1 int-rep RAX } } ?
    cpu x86.32? { { 2 double-rep ST0 } } { { 2 double-rep XMM0 } } ?
} [
    T{ alien-invoke-params { return int } } prepare-caller-return
    T{ alien-invoke-params { return double } } prepare-caller-return
] cfg-unit-test

! unbox-parameters

! unboxing ints is only needed on 32bit archs
cpu x86.32?
{
    { 2 4 }
    { { int-rep f f } { int-rep f f } }
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
    { { int-rep f f } { int-rep f f } }
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
