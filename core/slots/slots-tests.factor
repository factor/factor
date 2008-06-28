IN: slots.tests
USING: math accessors slots strings generic.standard kernel tools.test ;

TUPLE: r/w-test foo ;

TUPLE: r/o-test { "foo" read-only: t } ;

[ r/o-test new 123 >>foo ] [ no-method? ] must-fail-with

TUPLE: decl-test { "foo" integer } ;

[ decl-test new 1.0 >>foo ] [ bad-slot-value? ] must-fail-with

TUPLE: hello length ;

[ 3 ] [ "xyz" length>> ] unit-test

[ "xyz" 4 >>length ] [ no-method? ] must-fail-with
