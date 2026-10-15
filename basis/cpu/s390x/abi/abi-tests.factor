USING: accessors alien.c-types alien.complex arrays classes.struct
compiler.cfg.builder.alien.boxing compiler.cfg.instructions cpu.architecture
cpu.s390x.abi kernel namespaces sequences system tools.test ;
IN: cpu.s390x.abi.tests
STRUCT: one-float { x float } ;
STRUCT: one-double { x double } ;
STRUCT: nested-float { x one-float } ;
STRUCT: two-floats { x float } { y float } ;
STRUCT: three-bytes { x uchar[3] } ;
STRUCT: one-int { x uint } ;
STRUCT: three-ints { x uint } { y uint } { z uint } ;
UNION-STRUCT: float-union { x float } ;
{ float-rep } [ one-float fp-aggregate-rep ] unit-test
{ double-rep } [ one-double fp-aggregate-rep ] unit-test
{ float-rep } [ nested-float fp-aggregate-rep ] unit-test
{ f } [ two-floats fp-aggregate-rep ] unit-test
{ f } [ float-union fp-aggregate-rep ] unit-test
{ t } [ one-int lookup-c-type M\ s390x value-struct? execute ] unit-test
{ t } [ two-floats lookup-c-type M\ s390x value-struct? execute ] unit-test
{ f } [ three-bytes lookup-c-type M\ s390x value-struct? execute ] unit-test
{ f } [ three-ints lookup-c-type M\ s390x value-struct? execute ] unit-test
{ f } [ one-float lookup-c-type M\ s390x return-struct-in-registers? execute ] unit-test
{ f } [ one-int lookup-c-type M\ s390x return-struct-in-registers? execute ] unit-test
{ { 0 } { 4 } } [
    { int-rep } one-int lookup-c-type M\ s390x struct-components execute
    [ heap-size ] map
] unit-test
{ { 0 } { 4 } } [
    { float-rep } one-float lookup-c-type M\ s390x struct-components execute
    [ heap-size ] map
] unit-test
{ { { float-rep f f 4 } } } [
    0 int-reg-reps [ 0 float-reg-reps [
        one-float lookup-c-type M\ s390x flatten-struct-type execute
    ] with-variable ] with-variable
] unit-test

! Padded single-float structs use the aggregate container width; larger
! aligned structs are indirect, as verified against native GCC System z.
{ double-rep } [
    one-float lookup-c-type clone 8 >>size 8 >>align single-fp-rep
] unit-test
{ f } [
    one-float lookup-c-type clone 16 >>size 16 >>align single-fp-rep
] unit-test
{ f } [
    one-double lookup-c-type clone 16 >>size 16 >>align single-fp-rep
] unit-test

{ f } [ complex-float lookup-c-type M\ s390x value-struct? execute ] unit-test
{ f } [ complex-double lookup-c-type M\ s390x value-struct? execute ] unit-test
