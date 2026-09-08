USING: accessors compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.value-numbering compiler.test
kernel kernel.private layouts locals math math.bitwise math.floats.env math.private sequences
tools.test ;
IN: compiler.cfg.value-numbering.folding.tests

: has-integer>float? ( quot -- ? )
    [ ##integer>float? ] contains-insn? ;

! #1556: both branch-produced literals and literals selected by ?.
{ f } [ [ [ 3 ] [ 4 ] if fixnum>float ] has-integer>float? ] unit-test
{ f } [ [ { float object } declare 1 -1 ? - ] has-integer>float? ] unit-test
{ 3.0 } [ t [ [ 3 ] [ 4 ] if fixnum>float ] compile-call ] unit-test
{ 4.0 } [ f [ [ 3 ] [ 4 ] if fixnum>float ] compile-call ] unit-test
{ 9.0 } [ 10.0 t [ { float object } declare 1 -1 ? - ] compile-call ] unit-test
{ 11.0 } [ 10.0 f [ { float object } declare 1 -1 ? - ] compile-call ] unit-test

! Shared values must retain their integer representation.
{ f } [ [ [ 3 ] [ 4 ] if dup fixnum>float ] has-integer>float? ] unit-test
{ 3 3.0 } [ t [ [ 3 ] [ 4 ] if dup fixnum>float ] compile-call ] unit-test
{ 4 4.0 } [ f [ [ 3 ] [ 4 ] if dup fixnum>float ] compile-call ] unit-test
! A single input can feed multiple outputs of a phi.
{ f } [ [ [ 3 dup ] [ 4 dup ] if fixnum>float ] has-integer>float? ] unit-test
{ 3 3.0 } [ t [ [ 3 dup ] [ 4 dup ] if fixnum>float ] compile-call ] unit-test
{ 4 4.0 } [ f [ [ 3 dup ] [ 4 dup ] if fixnum>float ] compile-call ] unit-test
{ t } [ [ { fixnum object } declare [ ] [ drop 4 ] if fixnum>float ] has-integer>float? ] unit-test

! Inexact conversion remains at runtime to honor rounding modes and flags.
cell 8 = [
    { t } [ [ [ 0x20000000000001 ] [ 4 ] if fixnum>float ] has-integer>float? ] unit-test
] when

! Exercise CFG folding directly, independently of tree constant folding.
{
    {
        T{ ##load-integer { dst 0 } { val -3 } }
        T{ ##load-reference { dst 1 } { obj -3.0 } }
    }
} [
    {
        T{ ##load-integer { dst 0 } { val -3 } }
        T{ ##integer>float { dst 1 } { src 0 } }
    } value-numbering-step
] unit-test

{ t } [
    {
        T{ ##load-integer { dst 0 } { val 0x20000000000000 } }
        T{ ##integer>float { dst 1 } { src 0 } }
    } value-numbering-step last ##load-reference?
] unit-test

{ t } [
    {
        T{ ##load-integer { dst 0 } { val 0x20000000000001 } }
        T{ ##integer>float { dst 1 } { src 0 } }
    } value-numbering-step last ##integer>float?
] unit-test

! Compile before changing the FP environment so compiler activity cannot
! account for the observed rounding or exception flags.
cell 8 = [
    : selected-inexact-float ( ? -- x )
        [ 0x20000000000001 ] [ 4 ] if >float ;

    { 0x4340000000000000 } [
        +round-down+ [ t selected-inexact-float ] with-rounding-mode double>bits
    ] unit-test
    { 0x4340000000000001 } [
        +round-up+ [ t selected-inexact-float ] with-rounding-mode double>bits
    ] unit-test
    { t } [
        t [ selected-inexact-float ] collect-fp-exceptions
        nip +fp-inexact+ swap member?
    ] unit-test
    { f } [
        f [ selected-inexact-float ] collect-fp-exceptions
        nip +fp-inexact+ swap member?
    ] unit-test
] when

! Folded machine integers must retain target-width wrapping. In particular,
! a following signed comparison must see the same value as emitted code.
{ t } [
    [let
        cell-bits 1 - 2^ neg :> minimum
        {
            T{ ##load-integer { dst 0 } { val minimum } }
            T{ ##neg { dst 1 } { src 0 } }
            T{ ##compare-integer-imm { dst 2 } { src1 1 } { src2 0 } { cc cc< } }
        } value-numbering-step last obj>>
    ]
] unit-test

{ t } [
    [let
        cell-bits 1 - 2^ 1 - :> maximum
        {
            T{ ##load-integer { dst 0 } { val maximum } }
            T{ ##add-imm { dst 1 } { src1 0 } { src2 1 } }
            T{ ##compare-integer-imm { dst 2 } { src1 1 } { src2 0 } { cc cc< } }
        } value-numbering-step last obj>>
    ]
] unit-test

{ 0 } [
    [let
        cell-bits 2 - 2^ :> large
        {
            T{ ##load-integer { dst 0 } { val large } }
            T{ ##mul-imm { dst 1 } { src1 0 } { src2 4 } }
        } value-numbering-step last val>>
    ]
] unit-test
