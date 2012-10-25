! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test machine-learning.one-hot ;
IN: machine-learning.one-hot.tests

CONSTANT: test-data {
    { "male" "female" }
    { "from Europe" "from US" "from Asia" }
    { "uses Firefox" "uses Chrome" "uses Safari" "uses Internet Explorer" }
}

{ { 1 0 0 1 0 0 0 0 1 } }
[ { 0 1 3 } test-data one-hot ] unit-test
