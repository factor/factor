IN: http.server.validators.tests
USING: kernel sequences tools.test http.server.validators ;

[ t t ] [ "foo" [ v-number ] with-validator >r validation-error? r> ] unit-test
