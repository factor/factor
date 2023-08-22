! Copyright (C) 2010 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.random combinators.random.private tools.test ;

{ 1 } [ 1 [ 1 ] [ 2 ] ifp ] unit-test
{ 2 } [ 0 [ 1 ] [ 2 ] ifp ] unit-test

{ 3 }
[ { { 0 [ 1 ] }
    { 0 [ 2 ] }
    { 1 [ 3 ] }
    [ 4 ]
  } casep ] unit-test

{ 4 }
[ { { 0 [ 1 ] }
    { 0 [ 2 ] }
    { 0 [ 3 ] }
    [ 4 ]
  } casep ] unit-test

{ 1 1 } [ 1 {
    { 1 [ 1 ] }
    { 0 [ 2 ] }
    { 0 [ 3 ] }
    [ 4 ]
    } casep ] unit-test

{ 1 4 } [ 1 {
    { 0 [ 1 ] }
    { 0 [ 2 ] }
    { 0 [ 3 ] }
    [ 4 ]
    } casep ] unit-test

{ 2 } [ 0.7 {
    { 0.3 [ 1 ] }
    { 0.5 [ 2 ] }
    [ 2 ] } (casep) ] unit-test

{ { { 1/3 [ 1 ] }
    { 1/3 [ 2 ] }
    { 1/3 [ 3 ] } } }
[ { [ 1 ] [ 2 ] [ 3 ] } call-random>casep ] unit-test

{ { { 1/2 [ 1 ] }
    { 1/4 [ 2 ] }
    { 1/4 [ 3 ] } } }
[ { { 1/2 [ 1 ] }
    { 1/2 [ 2 ] }
    { 1 [ 3 ] } } direct>conditional ] unit-test

{ { { 1/2 [ 1 ] }
    { 1/4 [ 2 ] }
    { [ 3 ] } } }
[ { { 1/2 [ 1 ] }
    { 1/2 [ 2 ] }
    { [ 3 ] } } direct>conditional ] unit-test

{ f } [ { { 0.6 [ 1 ] }
  { 0.6 [ 2 ] } } good-probabilities? ] unit-test
{ f } [ { { 0.3 [ 1 ] }
  { 0.6 [ 2 ] } } good-probabilities? ] unit-test
{ f } [ { { -0.6 [ 1 ] }
  { 1.4 [ 2 ] } } good-probabilities? ] unit-test
{ f } [ { { -0.6 [ 1 ] }
  [ 2 ] } good-probabilities? ] unit-test
{ t } [ { { 0.6 [ 1 ] }
  [ 2 ] } good-probabilities? ] unit-test
{ t } [ { { 0.6 [ 1 ] }
  { 0.4 [ 2 ] } } good-probabilities? ] unit-test
