IN: http.server.validators.tests
USING: kernel sequences tools.test http.server.validators
accessors ;

[ "foo" v-number ] [ validation-error? ] must-fail-with

[ "slava@factorcode.org" ] [
    "slava@factorcode.org" v-email
] unit-test

[ "slava+foo@factorcode.org" ] [
    "slava+foo@factorcode.org" v-email
] unit-test

[ "slava@factorcode.o" v-email ]
[ "invalid e-mail" = ] must-fail-with

[ "sla@@factorcode.o" v-email ]
[ "invalid e-mail" = ] must-fail-with

[ "slava@factorcodeorg" v-email ]
[ "invalid e-mail" = ] must-fail-with
