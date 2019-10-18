IN: scratchpad
USE: parser
USE: test
USE: unparser

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
