USING: kernel sequences tools.test validators accessors
namespaces assocs ;

{ t } [ "on" v-checkbox ] unit-test
{ f } [ "off" v-checkbox ] unit-test

{ "default test" } [ "" "default test" v-default ] unit-test
{ "blah" } [ "blah" "default test" v-default ] unit-test

[ "foo" v-number ] must-fail
{ 123 } [ "123" v-number ] unit-test
{ 123 } [ "123" v-integer ] unit-test

[ "1.0" v-integer ] [ "must be an integer" = ] must-fail-with

{ "slava@factorcode.org" } [
    "slava@factorcode.org" v-email
] unit-test

{ "slava+foo@factorcode.org" } [
    "slava+foo@factorcode.org" v-email
] unit-test

[ "slava@factorcode.o" v-email ]
[ "invalid e-mail" = ] must-fail-with

[ "sla@@factorcode.o" v-email ]
[ "invalid e-mail" = ] must-fail-with

[ "slava@factorcodeorg" v-email ]
[ "invalid e-mail" = ] must-fail-with

{ "http://www.factorcode.org" }
[ "http://www.factorcode.org" v-url ] unit-test

[ "http:/www.factorcode.org" v-url ]
[ "invalid URL" = ] must-fail-with

[ "" v-one-line ] must-fail
{ "hello world" } [ "hello world" v-one-line ] unit-test
[ "hello\nworld" v-one-line ] must-fail

[ "" v-one-word ] must-fail
{ "hello" } [ "hello" v-one-word ] unit-test
[ "hello world" v-one-word ] must-fail

{ 4561261212345467 } [ "4561261212345467" v-credit-card ] unit-test

{ 4561261212345467 } [ "4561-2612-1234-5467" v-credit-card ] unit-test

{ 0 } [ "0000000000000000" v-credit-card ] unit-test

[ "000000000" v-credit-card ] must-fail

[ "0000000000000000000000000" v-credit-card ] must-fail

[ "4561_2612_1234_5467" v-credit-card ] must-fail

[ "4561-2621-1234-5467" v-credit-card ] must-fail

{ t } [ "http://double.co.nz/w?v=foo" dup v-url = ] unit-test
