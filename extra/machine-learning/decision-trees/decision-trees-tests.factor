! Copyright (C) 2018 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license
USING: formatting kernel machine-learning.data-sets
machine-learning.decision-trees sequences tools.test ;
IN: machine-learning.decision-trees.tests

: monks-gains ( name -- seq )
    load-monks 6 <iota> [ average-gain "%.3f" sprintf ] with map ;

{
    { "0.075" "0.006" "0.005" "0.026" "0.287" "0.001" }
    { "0.004" "0.002" "0.001" "0.016" "0.017" "0.006" }
    { "0.007" "0.294" "0.001" "0.003" "0.256" "0.007" }
} [
    "monks-1.train" monks-gains
    "monks-2.train" monks-gains
    "monks-3.train" monks-gains
] unit-test

{ 4 } [
    "monks-1.train" load-monks highest-gain-index
] unit-test
