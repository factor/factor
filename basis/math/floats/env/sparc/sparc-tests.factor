USING: accessors arrays kernel math.floats.env math.floats.env.private
math.floats.env.sparc sequences tools.test ;
IN: math.floats.env.sparc.tests

{ t } [
    all-fp-exceptions [
        1array dup set-fp-exception-flags fp-exception-flags =
    ] all? clear-fp-exception-flags
] unit-test

{ t } [
    { +round-nearest+ +round-zero+ +round-up+ +round-down+ }
    [ dup [ rounding-mode = ] with-rounding-mode ] all?
] unit-test

{ { } } [ fp-traps ] unit-test
{ +denormal-keep+ } [ denormal-mode ] unit-test
[ +denormal-flush+ set-denormal-mode ]
[ unsupported-sparc-denormal-mode? ] must-fail-with
{ +denormal-keep+ } [ denormal-mode ] unit-test
