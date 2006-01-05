IN: temporary
USE: parser
USE: test
USE: lists
USE: kernel
USE: generic
USE: words

[ 1 CHAR: a ]
[ 0 "abcd" next-char ] unit-test

[ 6 CHAR: \s ]
[ 1 "\\u0020hello" next-escape ] unit-test

[ 2 CHAR: \n ]
[ 1 "\\nhello" next-escape ] unit-test

[ 6 CHAR: \s ]
[ 0 "\\u0020hello" next-char ] unit-test

[ [ 1 [ 2 [ 3 ] 4 ] 5 ] ]
[ "1\n[\n2\n[\n3\n]\n4\n]\n5" parse ]
unit-test

[ [ t t f f ] ]
[ "t t f f" parse ]
unit-test

[ [ "hello world" ] ]
[ "\"hello world\"" parse ]
unit-test

[ [ "\n\r\t\\" ] ]
[ "\"\\n\\r\\t\\\\\"" parse ]
unit-test

[ "hello world" ]
[
    "IN: temporary : hello \"hello world\" ;"
    parse call "USE: scratchpad hello" eval
] unit-test

[ ]
[ "! This is a comment, people." parse call ]
unit-test

[ ]
[ "( This is a comment, people. )" parse call ]
unit-test

! Test escapes

[ [ " " ] ]
[ "\"\\u0020\"" parse ]
unit-test

[ [ "'" ] ]
[ "\"\\u0027\"" parse ]
unit-test

[ "\\u123" parse ] unit-test-fails

! Test improper lists

[ 2 ] [ "[[ 1 2 ]]" parse car cdr ] unit-test
[ "hello" ] [ "[[ 1 \"hello\" ]]" parse car cdr ] unit-test
[ C{ 1 2 } ] [ "[[ 1 C{ 1 2 } ]]" parse car cdr ] unit-test

! Test EOL comments in multiline strings.
[ [ "Hello" ] ] [ "#! This calls until-eol.\n\"Hello\"" parse ] unit-test 

[ word ] [ \ f class ] unit-test
