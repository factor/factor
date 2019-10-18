USING: definitions help help.markup kernel sequences tools.test
words parser namespaces assocs generic io.streams.string ;
IN: temporary

TUPLE: blahblah quux ;

: test-slot blahblah "slots" word-prop second ;

[
    { { "blahblah" { $instance blahblah } } { "quux" { $instance object } } }
] [
    test-slot blahblah ($spec-reader-values)
] unit-test

[ ] [
    test-slot blahblah $spec-reader-values
] unit-test

[ "an int" ] [ [ { "int" } $instance ] string-out ] unit-test

[ ] [ \ blahblah-quux help ] unit-test
[ ] [ \ set-blahblah-quux help ] unit-test
[ ] [ \ blahblah? help ] unit-test

: fooey "fooey" throw ;

[ ] [ \ fooey help ] unit-test

[ ] [ gensym help ] unit-test
