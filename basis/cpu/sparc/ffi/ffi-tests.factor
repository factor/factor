! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.complex arrays assocs classes.struct
compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params cpu.architecture cpu.sparc.ffi
kernel layouts locals math namespaces sequences system tools.test ;
IN: cpu.sparc.ffi.tests

STRUCT: sparc-doubles { first double } { second double } ;
STRUCT: sparc-floats { first float } { second float } ;
STRUCT: sparc-mixed { first int } { second float } ;
UNION-STRUCT: sparc-single-union { value double } ;
STRUCT: sparc-single-double { value double } ;

{ { int-rep double-rep int-rep double-rep } } [
    sparc-doubles sparc-struct-reps keys
] unit-test
{ { int-rep float-rep float-rep } } [
    sparc-floats sparc-struct-reps keys
] unit-test
{ { int-rep float-rep } } [
    sparc-mixed sparc-struct-reps keys
] unit-test
{ { 0 0 4 } } [
    sparc-floats sparc-struct-reps [ 8 swap nth offset>> ] map
] unit-test

! A spilled GP argument still consumes its positional floating slot.
{ { 8 9 10 11 12 13 14 } { 48 } 64 } [
    sparc.64 \ cpu [
        cdecl [
            7 <iota> [ 1 + { int-rep f f 8 } caller-parameter ] each
            8 { double-rep f f 8 } caller-parameter
        ] with-param-regs
        [ [ third ] map >array ] bi@ stack-params get
    ] with-variable
] unit-test

! FP shadows of a by-value object do not advance the parameter array.
{ { 8 9 2 10 4 } { } 24 } [
    sparc.64 \ cpu [
        cdecl [
            1 { int-rep f f 8 } caller-parameter
            sparc-doubles sparc-struct-reps
            [ 2 + swap caller-parameter ] each-index
        ] with-param-regs
        [ [ third ] map >array ] bi@ stack-params get
    ] with-variable
] unit-test
{ { 8 -1 0 } { } 8 } [
    sparc.64 \ cpu [
        cdecl [
            sparc-floats sparc-struct-reps
            [ 1 + swap caller-parameter ] each-index
        ] with-param-regs
        [ [ third ] map >array ] bi@ stack-params get
    ] with-variable
] unit-test

{ { 8 0 1 } } [
    sparc.64 \ cpu [
        sparc-floats sparc-struct-reps [ abi-return-register ] map
    ] with-variable
] unit-test

{ 4 0 0 t } [
    sparc.32 \ cpu [
        24 sparc-floats cdecl stack-cleanup
        24 int cdecl stack-cleanup
        0 void cdecl stack-cleanup
        return-struct-pointer?
    ] with-variable
] unit-test
{ 0 t } [ sparc.64 \ cpu [ 24 sparc-floats cdecl stack-cleanup return-struct-pointer? ] with-variable ] unit-test

! C complex results use FP registers and have no V8 UNIMP return marker.
{ t t f 0 0 } [
    sparc.32 \ cpu [
        complex-float return-struct-in-registers?
        complex-double base-type return-struct-in-registers?
        sparc-floats return-struct-in-registers?
        0 complex-float cdecl stack-cleanup
        0 complex-double cdecl stack-cleanup
    ] with-variable
] unit-test
{ { 0 1 } { 0 2 4 6 } } [
    sparc.32 \ cpu [
        complex-float return-regs-for-type float-regs of
        complex-double return-regs-for-type float-regs of
    ] with-variable
] unit-test

! Even a one-member floating union uses the integer ABI bank.
{ { int-rep } } [ sparc-single-union sparc-struct-reps keys ] unit-test
{ { int-rep double-rep } } [ sparc-single-double sparc-struct-reps keys ] unit-test
