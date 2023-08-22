! Copyright (C) 2009 Jason W. Merrill.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math.dual kernel accessors math math.functions
math.constants ;

{ 0.0 1.0 } [ 0 1 <dual> dsin unpack-dual ] unit-test
{ 1.0 0.0 } [ 0 1 <dual> dcos unpack-dual ] unit-test
{ 3 5 } [ 1 5 <dual> 2 d+ unpack-dual ] unit-test
{ 0 -1 } [ 1 5 <dual> 1 6 <dual> d- unpack-dual ] unit-test
{ 2 1 } [ 2 3 <dual> 1 -1 <dual> d* unpack-dual ] unit-test
{ 1/2 -1/4 } [ 2 1 <dual> 1 swap d/ unpack-dual ] unit-test
{ 2 } [ 1 1 <dual> 2 d^ epsilon-part>> ] unit-test
{ 2.0 .25 } [ 4 1 <dual> dsqrt unpack-dual ] unit-test
{ 2 -1 } [ -2 1 <dual> dabs unpack-dual ] unit-test
{ -2 -1 } [ 2 1 <dual> dneg unpack-dual ] unit-test
