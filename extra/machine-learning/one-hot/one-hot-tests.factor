! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
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

{ { 1 0 0 0 0 1 1 0 0 0 1 0 1 1 0 0 } }
[ { 0 3 0 2 1 0 } test-data one-hot ] unit-test

{ { 0 1 0 0 1 0 0 1 0 1 0 1 0 0 1 0 } }
[ { 1 2 1 1 0 1 } test-data one-hot ] unit-test
