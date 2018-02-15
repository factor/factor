! Copyright (C) 2018 Björn Lindqvist
! See http://factorcode.org/license.txt for BSD license
USING: kernel machine-learning.data-sets
machine-learning.decision-trees math.extras sequences tools.test ;

{ { 0.08 0.01 0.0 0.03 0.29 0.0 } } [
    "monks-1.train" load-monks
    6 <iota> [
        average-gain 2 round-to-decimal
    ] with map
] unit-test

{ 4 } [
    "monks-1.train" load-monks highest-gain-index
] unit-test
