IN: scratchpad

USE: parser
USE: test
USE: stack
USE: words
USE: strings

DEFER: foo

": foo 2 2 + . ; parsing" eval

[ [ ] ] [ "foo" parse ] unit-test

": foo 2 2 + . ;" eval

[ [ foo ] ] [ "foo" parse ] unit-test

! Test > 1 ( ) comment; only the first one should be used.
[ t ] [
    "a" ": foo ( a ) ( b ) ;" parse drop word stack-effect str-contains?
] unit-test
