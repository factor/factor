! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Positional register goldens independently inspected from GNU PA32 output.
USING: accessors arrays compiler.cfg.builder.alien.params cpu.architecture cpu.hppa.abi
cpu.hppa.assembler.registers kernel literals locals namespaces sequences
system tools.test vectors ;
IN: cpu.hppa.abi.tests
USING: alien.c-types ;
{ ${ R29 R28 } } [
    hppa.32 \ cpu [ <long-long-type> return-regs-for-type first second ] with-variable
] unit-test
{ ${ R28 R29 } } [
    hppa.32 \ cpu [ int return-regs-for-type first second ] with-variable
] unit-test
:: assign-parameters ( reps -- registers offsets bytes )
    hppa.32 \ cpu [
        f int-regs init-reg-class f float-regs init-reg-class
        0 stack-params set V{ } clone reg-values set V{ } clone stack-values set
        f compact-stack-params? set
        reps [| rep |
            rep prepare-parameter-group
            f rep first rep second rep third rep fourth next-parameter
        ] each
        reg-values get [ third ] map >array
        stack-values get [ third ] map >array stack-params get
    ] with-variable ;
{ ${ R26 F7 } { 16 } 20 } [
    ${ ${ int-rep f f 4 0 4 } ${ double-rep f f 8 0 8 } ${ int-rep f f 4 0 4 } }
    assign-parameters
] unit-test
{ ${ F5 F7 } { 16 } 24 } [
    ${ ${ double-rep f f 8 0 8 } ${ double-rep f f 8 0 8 } ${ double-rep f f 8 0 8 } }
    assign-parameters
] unit-test
{ ${ F4 F5 F6 F7 } { 16 } 20 } [
    ${ ${ float-rep f f 4 0 4 } ${ float-rep f f 4 0 4 }
       ${ float-rep f f 4 0 4 } ${ float-rep f f 4 0 4 } ${ float-rep f f 4 0 4 } }
    assign-parameters
] unit-test
{ ${ R26 R24 R23 } { } 16 } [
    ${ ${ int-rep f f 4 0 4 } ${ int-rep f t 4 0 8 } ${ int-rep f f 4 0 1 } }
    assign-parameters
] unit-test
USING: alien.c-types classes.struct compiler.cfg.builder.alien.boxing layouts math.order ;
STRUCT: hppa-large-record { a int } { b int } { c int } ;
{ t f } [
    hppa.32 \ cpu [ 4 \ cell [
        0 int-reg-reps set 0 float-reg-reps set
        hppa-large-record flatten-struct-type length 0 >
        hppa-large-record value-struct?
    ] with-variable ] with-variable
] unit-test
STRUCT: hppa-eight-record { a int } { b int } ;
{ ${ R26 R25 } { } 8 } [
    hppa.32 \ cpu [
        0 int-reg-reps set 0 float-reg-reps set
        hppa-eight-record flatten-struct-type
    ] with-variable assign-parameters
] unit-test
{ ${ R26 R24 R23 } { } 16 } [
    hppa.32 \ cpu [
        0 int-reg-reps set 0 float-reg-reps set
        ${ ${ int-rep f f 4 0 4 } } hppa-eight-record flatten-struct-type append
    ] with-variable assign-parameters
] unit-test
{ { 0 4 } { 4 4 } } [
    hppa.32 \ cpu [ { int-rep int-rep } hppa-eight-record struct-components [ size>> ] map ] with-variable
] unit-test

STRUCT: hppa-three-record { bytes uchar[3] } ;
STRUCT: hppa-seven-record { bytes uchar[7] } ;
{ ${ R26 } { } 4 } [
    hppa.32 \ cpu [ 0 int-reg-reps set 0 float-reg-reps set
        hppa-three-record flatten-struct-type ] with-variable assign-parameters
] unit-test
{ { 0 3 } { 3 4 } } [
    hppa.32 \ cpu [ { int-rep int-rep } hppa-seven-record struct-components
        [ size>> ] map ] with-variable
] unit-test
USING: compiler.cfg.instructions compiler.test make ;
{ { 5 6 7 } } [
    [ 42 5 int-rep 3 <hppa-struct-part> load-struct-component drop ] V{ } make
    [ ##load-memory-imm? ] filter [ offset>> ] map >array
] cfg-unit-test
{ { 5 6 7 } } [
    [ 2 42 5 int-rep 3 <hppa-struct-part> store-struct-component ] V{ } make
    [ ##store-memory-imm? ] filter [ offset>> ] map >array
] cfg-unit-test

! Shared mark-vararg-group metadata has first/last flags at positions5/6;
! alignment is position7. These are GNU PA32's positional GP/stack homes.
{ ${ R26 R25 R24 } { } 12 } [
    ${ ${ int-rep f f 4 0 4 } ${ int-rep f f 4 0 4 }
       ${ int-rep f f 4 0 t t 4 } } assign-parameters
] unit-test
{ ${ R26 R24 R23 } { } 16 } [
    ${ ${ int-rep f f 4 0 4 } ${ int-rep f f 4 0 t f 8 }
       ${ int-rep f f 4 0 f t 8 } } assign-parameters
] unit-test
{ ${ R26 R25 R24 } { 16 20 } 24 } [
    ${ ${ int-rep f f 4 0 4 } ${ int-rep f f 4 0 4 } ${ int-rep f f 4 0 4 }
       ${ int-rep f f 4 0 t f 8 } ${ int-rep f f 4 0 f t 8 } }
    assign-parameters
] unit-test
{ ${ R26 R25 R24 R23 } { 16 24 28 } 32 } [
    ${ ${ int-rep f f 4 0 4 } ${ int-rep f f 4 0 4 }
       ${ int-rep f f 4 0 4 } ${ int-rep f f 4 0 4 }
       ${ int-rep f f 4 0 t t 4 } ${ int-rep f f 4 0 t f 8 }
       ${ int-rep f f 4 0 f t 8 } } assign-parameters
] unit-test
