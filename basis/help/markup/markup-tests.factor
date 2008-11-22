USING: definitions help help.markup kernel sequences tools.test
words parser namespaces assocs generic io.streams.string accessors ;
IN: help.markup.tests

TUPLE: blahblah quux ;

[ "an int" ] [ [ { "int" } $instance ] with-string-writer ] unit-test

[ ] [ \ quux>> print-topic ] unit-test
[ ] [ \ >>quux print-topic ] unit-test
[ ] [ \ blahblah? print-topic ] unit-test

: fooey "fooey" throw ;

[ ] [ \ fooey print-topic ] unit-test

[ ] [ gensym print-topic ] unit-test
