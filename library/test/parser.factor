IN: scratchpad
USE: combinators
USE: parser
USE: test
USE: unparser

[ [ 1 [ 2 [ 3 ] 4 ] 5 ] ]
[ "1\n[\n2\n[\n3\n]\n4\n]\n5" ]
[ parse ]
test-word

[ [ t t f f ] ]
[ "t t f f" ]
[ parse ]
test-word

[ [ "hello world" ] ]
[ "\"hello world\"" ]
[ parse ]
test-word

[ [ "\n\r\t\\" ] ]
[ "\"\\n\\r\\t\\\\\"" ]
[ parse ]
test-word

[ "hello world" ]
[ "IN: scratchpad : hello \"hello world\" ;" ]
[ parse call "USE: scratchpad hello" eval ]
test-word

[ ]
[ "! This is a comment, people." ]
[ parse call ]
test-word

[ ]
[ "( This is a comment, people. )" ]
[ parse call ]
test-word

! Test escapes

[ [ " " ] ]
[ "\"\\u0020\"" ]
[ parse ]
test-word

[ [ "'" ] ]
[ "\"\\u0027\"" ]
[ parse ]
test-word
