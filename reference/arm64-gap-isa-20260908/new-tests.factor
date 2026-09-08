USING: alien.data byte-arrays compiler.codegen.labels compiler.test cpu.architecture
cpu.arm.64 cpu.arm.64.assembler.registers generic.parser kernel kernel.private make
math namespaces sequences tools.test ;
IN: cpu.arm.64.tests

! Constant (2^n + 1) multiplication selects a shifted ADD without a scratch.
{ B{ 32 4 1 139 } } [ [ X0 X1 3 %mul-imm ] B{ } make ] unit-test
{ B{ 0 12 0 139 } } [ [ X0 X0 9 %mul-imm ] B{ } make ] unit-test
USE: math.private
{ 21 } [ 7 [ { fixnum } declare 3 fixnum*fast ] compile-call ] unit-test
{ -63 } [ -7 [ { fixnum } declare 9 fixnum*fast ] compile-call ] unit-test
! MNEG supports destination/source aliasing.
{ B{ 32 252 2 155 } } [ [ X0 X1 X2 %mneg ] B{ } make ] unit-test
{ B{ 0 252 1 155 } } [ [ X0 X0 X1 %mneg ] B{ } make ] unit-test
{ B{ 32 252 0 155 } } [ [ X0 X1 X0 %mneg ] B{ } make ] unit-test
! The architecture default remains a portable MUL then NEG lowering.
{ 8 } [ [ X0 X1 X2 M\ object %mneg execute ] B{ } make length ] unit-test

USE: alien
QUALIFIED-WITH: alien.c-types c
QUALIFIED-WITH: cpu.arm.64.assembler a

: acquire-uint ( ptr -- n )
    c:uint { c:void* } cdecl [ W0 X0 a:LDAR ] alien-assembly ;
: release-uint ( n ptr -- )
    c:void { c:uint c:void* } cdecl [ W0 X1 a:STLR ] alien-assembly ;

{ 3735928559 } [ 0 c:uint <ref> [ 3735928559 swap release-uint ] keep acquire-uint ] unit-test

: increment-exclusive ( ptr -- n )
    c:uint { c:void* } cdecl [
        <label> [ resolve-label ] keep
        W1 X0 a:LDAXR
        W1 W1 1 a:ADD
        W2 W1 X0 a:STLXR
        W2 swap a:CBNZ
        W0 W1 a:MOV
    ] alien-assembly ;

{ 42 42 } [ 41 c:uint <ref> [ increment-exclusive ] keep acquire-uint ] unit-test

: scalar-fused-add ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FMADDs ] alien-assembly ;
: scalar-fused-subtract ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FMSUBs ] alien-assembly ;
: scalar-negated-fused-add ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FNMADDs ] alien-assembly ;
: scalar-negated-fused-subtract ( a b c -- x )
    c:double { c:double c:double c:double } cdecl
    [ D0 D0 D1 D2 a:FNMSUBs ] alien-assembly ;

{ 10.0 } [ 2.0 3.0 4.0 scalar-fused-add ] unit-test
{ -2.0 } [ 2.0 3.0 4.0 scalar-fused-subtract ] unit-test
{ -10.0 } [ 2.0 3.0 4.0 scalar-negated-fused-add ] unit-test
{ 2.0 } [ 2.0 3.0 4.0 scalar-negated-fused-subtract ] unit-test
! A cancellation whose low product bits would disappear with two roundings.
{ -4.930380657631324e-32 } [
    1.0000000000000002 0.9999999999999998 -1.0 scalar-fused-add
] unit-test
