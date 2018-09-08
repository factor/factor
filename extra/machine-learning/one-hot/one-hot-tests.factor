! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test machine-learning.one-hot ;
IN: machine-learning.one-hot.tests

CONSTANT: test-data {
    { "hot" "cold" }
    { "cloudy" "raining" "snowing" "sunny" }
    { "light" "heavy" }
    { "bright-colored" "dark-colored" "neutral" }
    { "quickly" "slowly" }
    { "well" "sick" "tired" }
}

! encode { hot sunny light neutral slowly well }
{ { 1 0 0 0 0 1 1 0 0 0 1 0 1 1 0 0 } }
[ test-data { 0 3 0 2 1 0 } one-hot ] unit-test

{ { 0 1 0 0 1 0 0 1 0 1 0 1 0 0 1 0 } }
[ test-data { 1 2 1 1 0 1 } one-hot ] unit-test

! need an index for each category, e.g. 6 indices
[ test-data { 1 2 } one-hot ]
[ one-hot-length-mismatch? ] must-fail-with

! last category is not within { well sick tired }
[ test-data { 1 2 1 1 0 10 } one-hot ]
[ one-hot-input-out-of-bounds? ] must-fail-with