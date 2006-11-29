USING: kernel parser sequences test words ;
IN: temporary

DEFER: foo

"IN: temporary : foo 2 2 + . ; parsing" eval

[ [ ] ] [ "USE: temporary foo" parse ] unit-test

"IN: temporary : foo 2 2 + . ;" eval

[ [ POSTPONE: foo ] ] [ "USE: temporary foo" parse ] unit-test
