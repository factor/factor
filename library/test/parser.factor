IN: scratchpad
USE: parser
USE: test
USE: unparser
USE: lists
USE: kernel
USE: generic
USE: words

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

! Test improper lists

[ 2 ] [ "[[ 1 2 ]]" parse car cdr ] unit-test
[ "hello" ] [ "[[ 1 \"hello\" ]]" parse car cdr ] unit-test
[ #{ 1 2 }# ] [ "[[ 1 #{ 1 2 }# ]]" parse car cdr ] unit-test

! Test EOL comments in multiline strings.
[ [ "Hello" ] ] [ "#! This calls until-eol.\n\"Hello\"" parse ] unit-test 

[ 4 ] [ "2 2 +" eval-catch ] unit-test
[ "4\n" ] [ "2 2 + ." eval>string ] unit-test
[ ] [ "fdafdf" eval-catch ] unit-test

[ word ] [ \ f class ] unit-test
