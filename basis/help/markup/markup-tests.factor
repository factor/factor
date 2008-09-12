USING: definitions help help.markup kernel sequences tools.test
words parser namespaces assocs generic io.streams.string accessors ;
IN: help.markup.tests

TUPLE: blahblah quux ;

[ "an int" ] [ [ { "int" } $instance ] with-string-writer ] unit-test

[ ] [ \ quux>> help ] unit-test
[ ] [ \ >>quux help ] unit-test
[ ] [ \ blahblah? help ] unit-test

: fooey "fooey" throw ;

[ ] [ \ fooey help ] unit-test

[ ] [ gensym help ] unit-test
