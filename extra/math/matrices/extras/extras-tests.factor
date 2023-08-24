! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, and Cat Stevens.
USING: arrays combinators.short-circuit grouping kernel math
math.matrices math.matrices.extras math.matrices.extras.private
math.statistics math.vectors sequences sequences.deep sets
tools.test ;
IN: math.matrices.extras

<PRIVATE
: call-eq? ( obj quots -- ? )
    [ call( x -- x ) ] with map all-eq? ; !  inline
PRIVATE>

{ {
    { 4181 6765 }
    { 6765 10946 }
} } [
  { { 0 1 } { 1 1 } } 20 m^n
] unit-test

[ { { 0 1 } { 1 1 } } -20 m^n ] [ negative-power-matrix? ] must-fail-with
[ { { 0 1 } { 1 1 } } -8 m^n ] [ negative-power-matrix? ] must-fail-with

{ { 1 -2 3 -4 } } [ { 1 2 3 4 } t alternating-sign ] unit-test
{ { -1 2 -3 4 } } [ { 1 2 3 4 } f alternating-sign ] unit-test


{ t } [ 50 <box-matrix> dup transpose = ] unit-test
{ t } [ 50 <box-matrix> dup                  anti-transpose = ] unit-test
{ f } [ 4 <box-matrix> zero-matrix? ] unit-test

{ t } [ 2 4 15 <random-integer-matrix> mabs {
    [ flatten [ 15 <= ] all? ]
    [ regular-matrix? ]
    [ length 2 = ]
    [ first length 4 = ]
} 1&& ] unit-test

{ t } [ 4 4 -45 <random-integer-matrix> mabs {
    [ flatten [ 45 <= ] all? ]
    [ regular-matrix? ]
    [ length 4 = ]
    [ first length 4 = ]
} 1&& ] unit-test

{ t } [ 2 2 1 <random-integer-matrix> mabs {
    [ flatten [ 1 <= ] all? ]
    [ regular-matrix? ]
    [ length 2 = ]
    [ first length 2 = ]
} 1&& ] unit-test

{ t } [ 2 4 .89 <random-unit-matrix> mabs {
    [ flatten [ .89 <= ] all? ]
    [ regular-matrix? ]
    [ length 2 = ]
    [ first length 4 = ]
} 1&& ] unit-test

{ t } [ 2 4 -45.89 <random-unit-matrix> mabs {
    [ flatten [ 45.89 <= ] all? ]
    [ regular-matrix? ]
    [ length 2 = ]
    [ first length 4 = ]
} 1&& ] unit-test

{ t } [ 4 4 .89 <random-unit-matrix> mabs {
    [ flatten [ .89 <= ] all? ]
    [ regular-matrix? ]
    [ length 4 = ]
    [ first length 4 = ]
} 1&& ] unit-test

{ {
    { 1   1/2 1/3 1/4 }
    { 1/2 1/3 1/4 1/5 }
    { 1/3 1/4 1/5 1/6 }
} } [ 3 4 <hilbert-matrix> ] unit-test

{ {
    { 1 2 3 4 }
    { 2 1 2 3 }
    { 3 2 1 2 }
    { 4 3 2 1 }
} } [ 4 <toeplitz-matrix> ] unit-test

{ {
    { 1 2 3 4 }
    { 2 3 4 0 }
    { 3 4 0 0 }
    { 4 0 0 0 } }
} [ 4 <hankel-matrix> ] unit-test

{ {
    { 1 1 1 }
    { 4 2 1 }
    { 9 3 1 }
    { 25 5 1 } }
} [
    { 1 2 3 5 } 3 <vandermonde-matrix>
] unit-test

{ {
    { 0 5 0 10 }
    { 6 7 12 14 }
    { 0 15 0 20 }
    { 18 21 24 28 }
} } [ {
    { 1 2 }
    { 3 4 }
} {
    { 0 5 }
    { 6 7 }
} kronecker-product ] unit-test

{ {
    { 1  1  1  1 }
    { 1 -1  1 -1 }
    { 1  1 -1 -1 }
    { 1 -1 -1  1 }
} } [ {
    { 1  1 }
    { 1 -1 }
} dup kronecker-product ] unit-test

{ {
    { 1 1 1 1 1 1 1 1 }
    { 1 -1 1 -1 1 -1 1 -1 }
    { 1 1 -1 -1 1 1 -1 -1 }
    { 1 -1 -1 1 1 -1 -1 1 }
    { 1 1 1 1 -1 -1 -1 -1 }
    { 1 -1 1 -1 -1 1 -1 1 }
    { 1 1 -1 -1 -1 -1 1 1 }
    { 1 -1 -1 1 -1 1 1 -1 }
} } [ {
    { 1 1 }
    { 1 -1 }
} dup dup kronecker-product kronecker-product ] unit-test

{ {
    { 1 1 1 1 1 1 1 1 }
    { 1 -1 1 -1 1 -1 1 -1 }
    { 1 1 -1 -1 1 1 -1 -1 }
    { 1 -1 -1 1 1 -1 -1 1 }
    { 1 1 1 1 -1 -1 -1 -1 }
    { 1 -1 1 -1 -1 1 -1 1 }
    { 1 1 -1 -1 -1 -1 1 1 }
    { 1 -1 -1 1 -1 1 1 -1 }
} } [ {
    { 1 1 }
    { 1 -1 }
} dup dup kronecker-product swap kronecker-product ] unit-test


! kronecker-product is not generally commutative, make sure we have the right order
{ {
    { 1 2 3 4 5 1 2 3 4 5 }
    { 6 7 8 9 10 6 7 8 9 10 }
    { 1 2 3 4 5 -1 -2 -3 -4 -5 }
    { 6 7 8 9 10 -6 -7 -8 -9 -10 }
} } [ {
    { 1 1 }
    { 1 -1 }
} {
    { 1 2 3 4 5 }
    { 6 7 8 9 10 }
} kronecker-product ] unit-test

{ {
    { 1 1 2 2 3 3 4 4 5 5 }
    { 1 -1 2 -2 3 -3 4 -4 5 -5 }
    { 6 6 7 7 8 8 9 9 10 10 }
    { 6 -6 7 -7 8 -8 9 -9 10 -10 }
} } [ {
    { 1 1 }
    { 1 -1 }
} {
    { 1 2 3 4 5 }
    { 6 7 8 9 10 }
} swap kronecker-product ] unit-test

{ {
    { 5 10 15 }
    { 6 12 18 }
    { 7 14 21 }
} } [
    { 5 6 7 }
    { 1 2 3 }
    outer-product
] unit-test


CONSTANT: test-points {
    { 80  27  89 } { 80  27  88 } { 75  25  90 }
    { 62  24  87 } { 62  22  87 } { 62  23  87 }
    { 62  24  93 } { 62  24  93 } { 58  23  87 }
    { 58  18  80 } { 58  18  89 } { 58  17  88 }
    { 58  18  82 } { 58  19  93 } { 50  18  89 }
    { 50  18  86 } { 50  19  72 } { 50  19  79 }
    { 50  20  80 } { 56  20  82 } { 70  20  91 }
}

{ {
    { 84+2/35 22+23/35 24+4/7 }
    { 22+23/35 9+104/105 6+87/140 }
    { 24+4/7 6+87/140 28+5/7 }
} } [ test-points sample-covariance-matrix ] unit-test

{ {
    { 80+8/147 21+85/147 23+59/147 }
    { 21+85/147 9+227/441 6+15/49 }
    { 23+59/147 6+15/49 27+17/49 }
} } [ test-points covariance-matrix ] unit-test

{
    {
        { 80+8/147 21+85/147 23+59/147 }
        { 21+85/147 9+227/441 6+15/49 }
        { 23+59/147 6+15/49 27+17/49 }
    }
} [
    test-points population-covariance-matrix
] unit-test

{ t } [ { { 1 } }
    { [ drop 1 ] [ (1determinant) ] [ 1 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ 0 } [ { { 0 } } determinant ] unit-test

{ t } [ {
    { 4 6 } ! order is significant
    { 3 8 }
} { [ drop 14 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 3 8 }
    { 4 6 }
} { [ drop -14 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 5 }
    { 1 -3 }
} { [ drop -11 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 1 -3 }
    { 2 5 }
} { [ drop 11 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 3 0 -1 }
    { 2 -5 4 }
    { -3 1 3 }
} { [ drop -44 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 3 0 -1 }
    { -3 1 3 }
    { 2 -5 4 }
} { [ drop 44 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 -3 1 }
    { 4 2 -1 }
    { -5 3 -2 }
} { [ drop -19 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 -3 1 }
    { -5 3 -2 }
    { 4 2 -1 }
} { [ drop 19 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 4 2 -1 }
    { 2 -3 1 }
    { -5 3 -2 }
} { [ drop 19 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 5 1 -2 }
    { -1 0 4 }
    { 2 -3 3 }
} { [ drop 65 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 6 1 1 }
    { 4 -2 5 }
    { 2 8 7 }
} { [ drop -306 ] [ (3determinant) ]  [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { -5  4 -3  2 }
    { -2  1  0 -1 }
    { -2 -3 -4 -5  }
    {  0  2  0  4 }
} { [ drop -24 ] [ 4 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 4 2 2 }
    { 5 1 -6 10 }
    { 4 3 -1 7 }
    { 9 8 7 3 }
} { [ drop 272 ] [ 4 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ {
    { 2 2 2 }
    { -2 3 3 }
    { 0 -10 0 }
} } [ {
    { 3 0 2 }
    { 2 0 -2 }
    { 0 1 1 }
} >minors ] unit-test

! i think this unit test is wrong
! { {
!     { 1 -6 -13 }
!     { 0 0 0 }
!     { 1 -6 -13 }
! } } [ {
!     { 1 2 1 }
!     { 6 -1 0 }
!     { 1 -2 -1 }
! } >minors ] unit-test

{ {
    { 1 6 -13 }
    { 0 0 0 }
    { 1 6 -13 }
} } [ {
    { 1 -6 -13 }
    { 0 0 0 }
    { 1 -6 -13 }
} >cofactors ] unit-test
