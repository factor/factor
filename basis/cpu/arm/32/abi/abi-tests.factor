USING: arrays alien.c-types alien.complex compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params cpu.architecture cpu.arm.32
cpu.arm.32.abi cpu.arm.32.assembler cpu.arm.32.compiler-assembler generic kernel literals namespaces
sequences tools.test vectors system classes.struct ;
IN: cpu.arm.32.abi.tests
! A named complex return is an HFA in AAPCS-VFP, just as its resolved
! C type is. Base AAPCS still uses a result pointer for these sizes.
{ t t f f }
[ [
    f arm32-base-aapcs? set
    \ complex-float M\ arm.32 return-struct-in-registers? execute
    \ complex-double M\ arm.32 return-struct-in-registers? execute
    t arm32-base-aapcs? set
    \ complex-float M\ arm.32 return-struct-in-registers? execute
    \ complex-double M\ arm.32 return-struct-in-registers? execute
] with-scope ] unit-test
! GNU's fixed mixed caller places x8 at 16, y8 at 24, x9 at 32,
! and y9 at 40 after the core and VFP argument banks are exhausted.
{ 24 32 40 48 }
[ [
    20 stack-params set t compact-stack-params? set
    double-rep 8 M\ arm.32 alloc-abi-stack-param execute
    int-rep 4 M\ arm.32 alloc-abi-stack-param execute
    double-rep 8 M\ arm.32 alloc-abi-stack-param execute
    stack-params get
] with-scope ] unit-test
{ 24 32 }
[ [
    20 stack-params set f compact-stack-params? set
    double-rep 8 M\ arm.32 alloc-abi-stack-param execute
    stack-params get
] with-scope ] unit-test
${ S0 D1 S1 D2 }
[ [
    ${ S15 S14 S13 S12 S11 S10 S9 S8 S7 S6 S5 S4 S3 S2 S1 S0 } >vector float-regs set
    float-regs get pop
    prepare-double-parameter float-regs get pop
    float-regs get pop
    prepare-double-parameter float-regs get pop
] with-scope ] unit-test
{ t }
[ [ ${ S3 S1 } >vector float-regs set prepare-double-parameter float-regs get empty? ] with-scope ] unit-test

! The first core register is r1 after a preceding integer argument; the
! double-word argument must skip r1 and start at r2.
${ R2 }
[ [ ${ R3 R2 R1 } >vector dup
    M\ arm.32 prepare-long-long-registers execute pop
] with-scope ] unit-test
{ 8 }
[ [ V{ } clone int-regs set 4 stack-params set { int-rep f t }
    M\ arm.32 prepare-abi-parameter-group execute stack-params get
] with-scope ] unit-test

! HFAs need one consecutive run; a hole at s1 cannot join s4.
${ S4 S5 }
[ [
    ${ S15 S14 S13 S12 S11 S10 S9 S8 S7 S6 S5 S4 S1 } >vector float-regs set
    2 f prepare-vfp-group float-regs get pop float-regs get pop
] with-scope ] unit-test
${ D1 D2 }
[ [
    ${ S15 S14 S13 S12 S11 S10 S9 S8 S7 S6 S5 S4 S3 S2 S1 } >vector float-regs set
    2 t prepare-vfp-group float-regs get pop float-regs get pop
] with-scope ] unit-test

{ { { int-rep f t 4 } { int-rep f f 4 } } }
[ [ 0 int-reg-reps set 0 float-reg-reps set double base-floating-reps ] with-scope ] unit-test
{ { { int-rep f f 4 } } }
[ [ 0 int-reg-reps set 0 float-reg-reps set float base-floating-reps ] with-scope ] unit-test

! An unspilled composite can use the remaining GPRs then the stack.
{ 0 3 }
[ [
    ${ R3 R2 R1 } >vector int-regs set 0 stack-params set
    int-rep f f 4 4array 4 suffix dup prepare-core-parameter-group
    4 swap nth int-regs get length
] with-scope ] unit-test
! With an occupied stack argument area, the whole composite must spill.
{ 4 8 }
[ [
    ${ R3 R2 R1 } >vector int-regs set 4 stack-params set
    int-rep f t 4 4array 4 suffix dup prepare-core-parameter-group
    4 swap nth stack-params get
] with-scope ] unit-test

{ t t f f t t }
[ f openbsd base-aapcs-required? t openbsd base-aapcs-required?
  f linux base-aapcs-required? f netbsd base-aapcs-required?
  t linux base-aapcs-required? t netbsd base-aapcs-required? ] unit-test
! Base AAPCS uses core bits for scalar parameters and callback results.
{ { { int-rep f t 4 } { int-rep f f 4 } } { { int-rep f f 4 } } }
[ [ t arm32-base-aapcs? set 0 int-reg-reps set 0 float-reg-reps set
    double M\ arm.32 flatten-scalar-parameter execute
    float M\ arm.32 flatten-scalar-return execute ] with-scope ] unit-test
STRUCT: openbsd-hfa-pair { x double } { y double } ;
{ f t }
[ \ openbsd-hfa-pair lookup-c-type
  [ [ t arm32-base-aapcs? set M\ arm.32 return-struct-in-registers? execute ] with-scope ]
  [ [ f arm32-base-aapcs? set M\ arm.32 return-struct-in-registers? execute ] with-scope ] bi ] unit-test
