IN: scratchpad
USE: lists
USE: math
USE: parser
USE: test
USE: unparser
USE: kernel
USE: io-internals

[ "\"hello\\\\backslash\"" ]
[ "hello\\backslash" ]
[ unparse ]
test-word

[ "\"\\u1234\"" ]
[ "\u1234" ]
[ unparse ]
test-word

[ "\"\\e\"" ]
[ "\e" ]
[ unparse ]
test-word

[ "1.0" ] [ 1.0 unparse ] unit-test
[ "f" ] [ f unparse ] unit-test
[ "t" ] [ t unparse ] unit-test
[ "car" ] [ \ car unparse ] unit-test
[ "#{ 1/2 2/3 }#" ] [ #{ 1/2 2/3 }# unparse ] unit-test
[ "1267650600228229401496703205376" ] [ 1 100 shift unparse ] unit-test

[ ] [ { 1 2 3 } unparse drop ] unit-test
[ stdin unparse parse ] unit-test-fails
