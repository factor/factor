USING: definitions help help.markup kernel sequences tools.test
words parser namespaces assocs generic io.streams.string accessors
strings math ;
IN: help.markup.tests

TUPLE: blahblah quux ;

[ "int" ] [ [ { "int" } $instance ] with-string-writer ] unit-test

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

! Layout

[ "span" ]
[ [ { "span" } print-content ] with-string-writer ] unit-test

[ "span1span2" ]
[ [ { "span1" "span2" } print-content ] with-string-writer ] unit-test

[ "span1\n\nspan2" ]
[ [ { "span1" { $nl } "span2" } print-content ] with-string-writer ] unit-test

[ "\nspan" ]
[ [ { { $nl } "span" } print-content ] with-string-writer ] unit-test

[ "2 2 +\nspan" ]
[ [ { { $code "2 2 +" } "span" } print-content ] with-string-writer ] unit-test

[ "2 2 +" ]
[ [ { { $code "2 2 +" } } print-content ] with-string-writer ] unit-test

[ "span\n2 2 +" ]
[ [ { "span" { $code "2 2 +" } } print-content ] with-string-writer ] unit-test

[ "\n2 2 +" ]
[ [ { { $nl } { $code "2 2 +" } } print-content ] with-string-writer ] unit-test

[ "span\n\n2 2 +" ]
[ [ { "span" { $nl } { $code "2 2 +" } } print-content ] with-string-writer ] unit-test

[ "Heading" ]
[ [ { { $heading "Heading" } } print-content ] with-string-writer ] unit-test

[ "Heading1\n\nHeading2" ]
[ [ { { $heading "Heading1" } { $heading "Heading2" } } print-content ] with-string-writer ] unit-test

[ "span\n\nHeading" ]
[ [ { "span" { $heading "Heading" } } print-content ] with-string-writer ] unit-test

[ "\nHeading" ]
[ [ { { $nl } { $heading "Heading" } } print-content ] with-string-writer ] unit-test

[ "span\n\nHeading" ]
[ [ { "span" { $nl } { $heading "Heading" } } print-content ] with-string-writer ] unit-test
