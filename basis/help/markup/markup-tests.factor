USING: definitions help help.markup kernel sequences tools.test
words parser namespaces assocs generic io.streams.string accessors
strings math ;
IN: help.markup.tests

TUPLE: blahblah quux ;

[ "an int" ] [ [ { "int" } $instance ] with-string-writer ] unit-test

[ ] [ \ quux>> print-topic ] unit-test
[ ] [ \ >>quux print-topic ] unit-test
[ ] [ \ blahblah? print-topic ] unit-test

: fooey ( -- * ) "fooey" throw ;

[ ] [ \ fooey print-topic ] unit-test

[ ] [ gensym print-topic ] unit-test

[ "a string" ]
[ [ { $or string } print-element ] with-string-writer ] unit-test

[ "a string or an integer" ]
[ [ { $or string integer } print-element ] with-string-writer ] unit-test

[ "a string, a fixnum, or an integer" ]
[ [ { $or string fixnum integer } print-element ] with-string-writer ] unit-test

\ print-element must-infer
\ print-topic must-infer