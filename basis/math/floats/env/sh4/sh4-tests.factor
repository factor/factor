USING: accessors classes.struct kernel math.floats.env
math.floats.env.private math.floats.env.sh4 system tools.test ;
IN: math.floats.env.sh4.tests

{ +round-nearest+ } [ 0x80000 sh4-env boa (get-rounding-mode) ] unit-test
{ +round-zero+ } [ 0x80001 sh4-env boa (get-rounding-mode) ] unit-test
{ 0x380001 } [
    0x380000 sh4-env boa +round-zero+ (set-rounding-mode) fpscr>>
] unit-test
[ 0x80000 sh4-env boa +round-up+ (set-rounding-mode) ]
[ unsupported-sh4-rounding-mode? ] must-fail-with
[ 0x80000 sh4-env boa +round-down+ (set-rounding-mode) ]
[ unsupported-sh4-rounding-mode? ] must-fail-with
{ { +fp-zero-divide+ } } [
    0x80020 sh4-env boa (get-exception-flags)
] unit-test
{ 0x380040 } [
    0x380000 sh4-env boa { +fp-invalid-operation+ }
    (set-exception-flags) fpscr>>
] unit-test
{ 0x380400 } [
    0x380000 sh4-env boa { +fp-zero-divide+ } (set-fp-traps) fpscr>>
] unit-test
{ +denormal-flush+ } [ 0xc0000 sh4-env boa (get-denormal-mode) ] unit-test
{ 0x380000 } [
    0x3c0000 sh4-env boa +denormal-keep+ (set-denormal-mode) fpscr>>
] unit-test

{ t } [ +round-nearest+ M\ sh4 rounding-mode-supported? execute( mode -- ? ) ] unit-test
{ t } [ +round-zero+ M\ sh4 rounding-mode-supported? execute( mode -- ? ) ] unit-test
{ f } [ +round-up+ M\ sh4 rounding-mode-supported? execute( mode -- ? ) ] unit-test
{ f } [ +round-down+ M\ sh4 rounding-mode-supported? execute( mode -- ? ) ] unit-test
