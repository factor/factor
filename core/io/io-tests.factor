USING: io parser tools.test words ;
IN: io.tests

[ f ] [
    "vocab:io/test/no-trailing-eol.factor" run-file
    "foo" "io.tests" lookup
] unit-test

! Make sure we use correct to_c_string form when writing
[ ] [ "\0" write ] unit-test
