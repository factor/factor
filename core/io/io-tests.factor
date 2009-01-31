USING: arrays io io.files kernel math parser strings system
tools.test words namespaces make io.encodings.8-bit
io.encodings.binary sequences ;
IN: io.tests

[ f ] [
    "resource:core/io/test/no-trailing-eol.factor" run-file
    "foo" "io.tests" lookup
] unit-test

! Make sure we use correct to_c_string form when writing
[ ] [ "\0" write ] unit-test
