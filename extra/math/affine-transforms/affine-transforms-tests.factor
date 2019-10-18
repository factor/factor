! (c)2009 Joe Groff, see BSD license
USING: arrays kernel literals tools.test math math.affine-transforms
math.constants math.functions ;

{ { 7.25 4.25 } } [
    { 0.75 0.75 } { 0.75 -0.75 } { 5.0 5.0 } <affine-transform>
    { 1.0 2.0 } a.v
] unit-test

{ -1.125 } [
    { 0.75 0.75 } { 0.75 -0.75 } { 5.0 5.0 } <affine-transform>
    |a|
] unit-test

{ 1.0 3.0 } { 2.0 4.0 } { 5.0 6.0 } <affine-transform> 1array [
    { 1.0 2.0 } { 3.0 4.0 } { 5.0 6.0 } <affine-transform>
    transpose-axes
] unit-test

{ 1.0 -1.0 } { 1.0 1.0 } { 0.0 0.0 } <affine-transform> 1array [
    { 0.5 0.5 } { -0.5 0.5 } { 5.0 5.0 } <affine-transform>
    inverse-axes
] unit-test

{ 1.0 -1.0 } { 1.0 1.0 } { -10.0 0.0 } <affine-transform> 1array [
    { 0.5 0.5 } { -0.5 0.5 } { 5.0 5.0 } <affine-transform>
    inverse-transform
] unit-test

{ 1.0 0.0 } { 0.0 1.0 } { 0.0 0.0 } <affine-transform> 1array [
    { 0.5 0.5 } { -0.5 0.5 } { 5.0 5.0 } <affine-transform>
    dup inverse-transform a.
] unit-test

{ 2.0 -1.0 } { -1.0 -2.0 } { 5.0 -6.0 } <affine-transform> 1array [
    { 1.0 0.0 } { 0.0 -1.0 } { 0.0 0.0 } <affine-transform>
    { 2.0 1.0 } { -1.0 2.0 } { 5.0 6.0 } <affine-transform>
    a.
] unit-test

{ t } [
    { 0.01  0.02  } { 0.03  0.04  } { 0.05  0.06  } <affine-transform>
    { 0.011 0.021 } { 0.031 0.041 } { 0.051 0.061 } <affine-transform> 0.01 a~
] unit-test

{ 1.0 0.0 } { 0.0 1.0 } { 5.0 10.0 } <affine-transform> 1array [
    { 5.0 10.0 } <translation>
] unit-test

{ $[ pi  0.25 * cos ] $[ pi 0.25 * sin ] }
{ $[ pi -0.25 * sin ] $[ pi 0.25 * cos ] }
{ 0.0 0.0 } <affine-transform> 1array [
    pi 0.25 * <rotation>
] unit-test
