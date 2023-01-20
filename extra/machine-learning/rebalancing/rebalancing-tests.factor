! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel machine-learning.rebalancing math
math.statistics math.text.english sequences tools.test
math.vectors ;

{ t } [
    { 1 1 1 2 } [ [ number>text ] map ] [ ] bi
    100,000 balance-labels nip
    histogram values first2 - abs 3,000 <
] unit-test


{ t } [
    { 1 1 1 2 } [ [ number>text ] map ] [ ] bi
    { 1/10 9/10 } 100,000 skew-labels nip
    histogram values { 10,000 90,000 } -.05 v~
] unit-test
