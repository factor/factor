USING: literals accessors alien.accessors arrays compiler.cfg.instructions compiler.cfg.value-numbering
compiler.cfg.value-numbering.folding compiler.test cpu.architecture
kernel math math.floats.env math.floats.env.test-support math.vectors.simd sequences tools.test ;
IN: compiler.cfg.value-numbering.simd.tests

! Exactness is checked without narrowing, including the range boundaries.
{ { t t t t f f f f } } [
    { 0x0000000000000000 0x8000000000000000
      0x3810000000000000 0x47efffffe0000000
      0x380fffffc0000000 0x47f0000000000000
      0x3ff199999999999a 0x7ff0000000000001 }
    [ bits>double exact-single? ] map
] unit-test

{ t } [
    {
        T{ ##load-reference { dst 0 } { obj 1.1 } }
        T{ ##scalar>vector { dst 1 } { src 0 } { rep float-4-rep } }
    } value-numbering-step last ##scalar>vector?
] unit-test

{ t } [
    {
        T{ ##load-reference { dst 0 } { obj 1.1 } }
        T{ ##gather-vector-4 { dst 1 } { src1 0 } { src2 0 }
            { src3 0 } { src4 0 } { rep float-4-rep } }
    } value-numbering-step last ##gather-vector-4?
] unit-test

: inexact-vector ( -- x )
    1.1 float-4{ 0.0 0.0 0.0 0.0 } simd-with first ; inline

: exact-vector ( -- x )
    1.5 float-4{ 0.0 0.0 0.0 0.0 } simd-with first ; inline

! Scalar lowering can convert at runtime, call a primitive store, or load
! an exact single constant before a single-width store.
: narrowing-insn? ( insn -- ? )
    dup ##double>single-float? [ drop t ] [
        dup ##call? [ word>> \ set-alien-float eq? ] [
            dup [ ##store-memory? ] [ ##store-memory-imm? ] bi or
            [ rep>> float-rep eq? ] [ drop f ] if
        ] if
    ] if ;

{ t } [ [ inexact-vector ] [ narrowing-insn? ] contains-insn? ] unit-test
! An exact scalar avoids narrowing only with active native broadcast lowering.
$[ floating-point-supported?
   float-4-rep %shuffle-vector-imm-reps member? and not 1array ]
[ [ exact-vector ] [ narrowing-insn? ] contains-insn? ] unit-test

! Exact constants may use a direct single load or an exact conversion.
! Both lowerings must preserve the value under either rounding direction.
{ 0x3ff8000000000000 } [
    +round-down+ [ exact-vector double>bits ] with-rounding-mode
] +round-down+ rounding-mode-unit-test
{ 0x3ff8000000000000 } [
    +round-up+ [ exact-vector double>bits ] with-rounding-mode
] +round-up+ rounding-mode-unit-test

{ 0x3ff1999980000000 } [
    +round-down+ [ inexact-vector double>bits ] with-rounding-mode
] +round-down+ rounding-mode-unit-test
{ 0x3ff19999a0000000 } [
    +round-up+ [ inexact-vector double>bits ] with-rounding-mode
] +round-up+ rounding-mode-unit-test
{ t } [
    [ inexact-vector ] collect-fp-exceptions nip +fp-inexact+ swap member?
] floating-point-unit-test
{ f } [
    [ exact-vector ] collect-fp-exceptions nip +fp-inexact+ swap member?
] floating-point-unit-test
