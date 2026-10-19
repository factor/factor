! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.complex arrays assocs classes.struct compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
cpu.architecture cpu.sh cpu.sh.abi cpu.sh.assembler kernel math namespaces sequences
system tools.test vectors ;
IN: cpu.sh.abi.tests
STRUCT: byte-record { x uchar } ;
STRUCT: bytes-record { x uchar[4] } ;
STRUCT: pair-record { x int } { y int } ;
STRUCT: float-record { x alien.c-types:float } ;
STRUCT: double-record { x double } ;
STRUCT: mixed-record { x int } { y double } ;
STRUCT: text-record { x c-string } ;
PACKED-STRUCT: packed-record { x int } ;

: target ( quot: ( -- value ) -- value ) sh4.32 \ cpu rot with-variable ; inline
{ t } [ [ byte-record lookup-c-type return-struct-in-registers? ] target ] unit-test
{ f } [ [ bytes-record lookup-c-type return-struct-in-registers? ] target ] unit-test
{ t } [ [ pair-record lookup-c-type return-struct-in-registers? ] target ] unit-test
{ f } [ [ packed-record lookup-c-type return-struct-in-registers? ] target ] unit-test
! Call preparation receives the defining word; return boxing receives the
! resolved c-type. Both must classify the same hidden-result ABI.
{ f f } [
    [ mixed-record return-struct-in-registers?
      mixed-record lookup-c-type return-struct-in-registers? ] target
] unit-test
{ f f } [
    [ bytes-record return-struct-in-registers?
      bytes-record lookup-c-type return-struct-in-registers? ] target
] unit-test
{ t t } [
    [ pair-record return-struct-in-registers?
      pair-record lookup-c-type return-struct-in-registers? ] target
] unit-test
{ int-rep t } [ c-string lookup-c-type mode-info ] unit-test
{ t t } [
    [ text-record return-struct-in-registers?
      text-record lookup-c-type return-struct-in-registers? ] target
] unit-test
{ float-rep } [ float-record lookup-c-type mode-info drop ] unit-test
{ double-rep } [ double-record lookup-c-type mode-info drop ] unit-test
{ 4 } [ 4 <abi-float-register> double-rep abi-register ] unit-test
{ 5 } [ f sh-big-endian? [ 4 <abi-float-register> float-rep abi-register ] with-variable ] unit-test
{ 4 } [ t sh-big-endian? [ 4 <abi-float-register> float-rep abi-register ] with-variable ] unit-test
{ { 4 6 7 8 9 10 11 } } [
    [
        f float-regs init-reg-class
        { double-rep f f } prepare-abi-parameter-group
        float-regs get <reversed> [ n>> ] map >array
    ] target
] unit-test
{ { 6 8 9 10 11 } } [
    [
        f float-regs init-reg-class float-regs get pop* ! One preceding float.
        { double-rep f f } prepare-abi-parameter-group
        float-regs get <reversed> [ n>> ] map >array
    ] target
] unit-test

! The six-argument native gate fixture needs eight argument bytes and a
! separate linked header, rounded to the VM frame alignment.
{ 32 } [ 8 sh4.32 insert-trampoline-area ] unit-test
{ 0 } [ 0 sh4.32 insert-trampoline-area ] unit-test
{ t } [ sh4be.32 \ cpu [ big-endian-cpu? ] with-variable ] unit-test
{ f } [ sh4.32 \ cpu [ big-endian-cpu? ] with-variable ] unit-test

! Hard SH4 has no parity padding, but cannot split a pair at the GP limit.
{ { 4 5 } } [
    [ f int-regs init-reg-class
      long-long-odd-register? int-rep next-reg-param
      f int-rep next-reg-param 2array ] target
] unit-test
{ { 5 6 } } [
    [ f int-regs init-reg-class int-regs get pop*
      long-long-odd-register? int-rep next-reg-param
      f int-rep next-reg-param 2array ] target
] unit-test
{ t { } } [
    [ f int-regs init-reg-class 3 [ int-regs get pop* ] times
      int-regs get long-long-odd-register? reg-class-full?
      int-regs get >array ] target
] unit-test

! GCC -m4 stacks the entire record but preserves R7 for a later scalar.
{ { 7 } } [
    [ 0 stack-params set f compact-stack-params? set
      f int-regs init-reg-class 3 [ int-regs get pop* ] times
      pair-record lookup-c-type flatten-struct-type first prepare-parameter-group
      int-regs get >array ] target
] unit-test
{ { 7 6 5 } } [
    [ f int-regs init-reg-class int-regs get pop*
      pair-record lookup-c-type flatten-struct-type first prepare-parameter-group
      int-regs get >array ] target
] unit-test

! Native GNU keeps single-field FP records as opaque native payloads; the
! scalar FFI boundary alone converts between native and canonical NaNs.
{ t 4 } [
    [ 0 stack-params set f compact-stack-params? set
      V{ } clone reg-values set V{ } clone stack-values set
      f float-regs init-reg-class
      double-record lookup-c-type flatten-struct-type first prepare-parameter-group
      42 double-rep f f 8 alloc-abi-parameter drop
      reg-values get first third
      [ native-float-register? ] [ double-rep abi-register ] bi
    ] target
] unit-test
{ f } [
    [ f float-regs init-reg-class
      { double-rep f f } prepare-parameter-group
      42 double-rep f f 8 alloc-abi-parameter
    ] target
] unit-test
{ f } [
    [ f float-regs init-reg-class
      { double-rep f f 8 0 t t 8 } prepare-parameter-group
      42 double-rep f f 8 alloc-abi-parameter
    ] target
] unit-test
{ t } [
    [ double-record lookup-c-type return-regs-for-type float-regs swap at first
      native-float-register? ] target
] unit-test
{ f } [
    [ double return-regs-for-type float-regs swap at first
      native-float-register? ] target
] unit-test
: integer-target ( quot: ( -- value ) -- value )
    sh3.32 \ cpu rot with-variable ; inline
{ { 4 5 6 7 } } [ [ f param-regs int-regs of ] integer-target ] unit-test
{ { } } [ [ f param-regs float-regs of ] integer-target ] unit-test
{ { 0 1 } } [ [ return-regs int-regs of ] integer-target ] unit-test
{ { } } [ [ return-regs float-regs of ] integer-target ] unit-test
! A preceding int leaves R5 available for the first int64 half.
{ { 7 6 5 } } [
    [ f int-regs init-reg-class int-regs get pop*
      { int-rep f f } prepare-abi-parameter-group
      int-regs get >array ] integer-target
] unit-test
{ 2 } [ [ struct-return-register ] integer-target ] unit-test
{ t } [ [ pair-record lookup-c-type return-struct-in-registers? ] integer-target ] unit-test
{ f } [ [ bytes-record lookup-c-type return-struct-in-registers? ] integer-target ] unit-test

! C99 complex values use FP results even though their metadata is a record.
{ t t } [
    [ complex-float return-struct-in-registers?
      complex-double return-struct-in-registers? ] target
] unit-test
{ { float-rep float-rep } { double-rep double-rep } } [
    [ complex-float lookup-c-type flatten-struct-type-return keys
      complex-double lookup-c-type flatten-struct-type-return keys ] target
] unit-test
{ { 0 1 } { 0 2 } } [
    [ complex-float lookup-c-type return-regs-for-type float-regs swap at [ reg>> ] map
      complex-double lookup-c-type return-regs-for-type float-regs swap at [ reg>> ] map ] target
] unit-test

! Scalar return boxing supplies resolved c-types, while call preparation uses names.
{ t } [
    [ { int double void* bool c-string } [
        [ complex-c-type? not ] [ lookup-c-type complex-c-type? not ] bi and
      ] all? ] target
] unit-test
