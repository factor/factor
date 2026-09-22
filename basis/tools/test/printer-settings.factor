USING: kernel namespaces prettyprint prettyprint.config tools.test ;
IN: tools.test.printer-settings

{ "123" } [ 123 unparse ] unit-test
{ "0x7b" } [ 16 number-base [ 123 unparse ] with-variable ] unit-test

TUPLE: print-config-tuple x ;

{ "{ 1 2 3 }" } [ { 1 2 3 } unparse ] unit-test
{ "T{ print-config-tuple { x 123 } }" } [
    123 print-config-tuple boa unparse
] unit-test
