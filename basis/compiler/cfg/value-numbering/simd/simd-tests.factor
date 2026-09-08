USING: accessors compiler.cfg.instructions compiler.cfg.value-numbering
compiler.cfg.value-numbering.folding compiler.test cpu.architecture
kernel math math.floats.env math.vectors.simd sequences tools.test ;
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

! The CFG folder and representation selection must both preserve narrowing.
{ t } [ [ inexact-vector ] [ ##double>single-float? ] contains-insn? ] unit-test
{ f } [ [ exact-vector ] [ ##double>single-float? ] contains-insn? ] unit-test

{ 0x3ff1999980000000 } [
    +round-down+ [ inexact-vector double>bits ] with-rounding-mode
] unit-test
{ 0x3ff19999a0000000 } [
    +round-up+ [ inexact-vector double>bits ] with-rounding-mode
] unit-test
{ t } [
    [ inexact-vector ] collect-fp-exceptions nip +fp-inexact+ swap member?
] unit-test
{ f } [
    [ exact-vector ] collect-fp-exceptions nip +fp-inexact+ swap member?
] unit-test
