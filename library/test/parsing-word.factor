IN: scratchpad

USE: parser
USE: test

DEFER: foo

": foo 2 2 + . ; parsing" eval

[ [ ] ] [ "foo" parse ] unit-test

": foo 2 2 + . ;" eval

[ [ foo ] ] [ "foo" parse ] unit-test
