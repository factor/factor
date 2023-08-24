! Copyright (C) 2005, 2010, 2018, 2020 Slava Pestov, Joe Groff, and Cat Stevens.
USING: arrays assocs combinators.short-circuit grouping kernel
math math.statistics math.vectors sequences sequences.deep
tools.test ;
IN: math.matrices

<PRIVATE
: call-eq? ( obj quots -- ? )
    [ call( x -- x ) ] with map all-eq? ; !  inline
PRIVATE>
! ------------------------
! predicates

{ t } [ { }                 regular-matrix? ] unit-test
{ t } [ { { } }             regular-matrix? ] unit-test
{ t } [ { { 1 2 } }         regular-matrix? ] unit-test
{ t } [ { { 1 2 } { 3 4 } } regular-matrix? ] unit-test
{ t } [ { { 1 } { 3 } }     regular-matrix? ] unit-test
{ f } [ { { 1 2 } { 3 } }   regular-matrix? ] unit-test
{ f } [ { { 1 } { 3 2 } }   regular-matrix? ] unit-test


{ t } [ { } square-matrix? ] unit-test
{ t } [ { { 1 } } square-matrix? ] unit-test
{ t } [ { { 1 2 } { 3 4 } } square-matrix? ] unit-test
{ f } [ { { 1 } { 2 3 } } square-matrix? ] unit-test
{ f } [ { { 1 2 } } square-matrix? ] unit-test

! any deep-empty matrix is null
! it doesn't make any sense for { } to be null while { { } } to be considered nonnull
{ t } [ {
    { }
    { { } }
    { { { } } }
    { { } { } { } }
    { { { } } { { { } } } }
} [ null-matrix? ] all?
] unit-test

{ f } [ {
    { 1 2 }
    { { 1 2 } }
    { { 1 } { 2 } }
    { { { 1 } } { 2 } { } }
} [ null-matrix? ] any?
] unit-test

{ t } [ 10 dup <zero-matrix> zero-matrix? ] unit-test
{ t } [ 10 10 15 <simple-eye> zero-matrix? ] unit-test
{ t } [ 0 dup <zero-matrix> null-matrix? ] unit-test
{ f } [ 0 dup <zero-matrix> zero-matrix? ] unit-test
{ f } [ 4 <identity-matrix> zero-matrix? ] unit-test
! make sure we're not using the sum-to-zero strategy
{ f } [ { { 0 -2 } { 1 -1 } } zero-matrix? ] unit-test
{ f } [ { { 0 0 } { 1 -1 } } zero-matrix? ] unit-test
{ f } [ { { 0 1 } { 0 -1 } } zero-matrix? ] unit-test

! nth etc

{ 3 } [ { 1 2 3 } 0 swap nth-end ] unit-test
{ 2 } [ { 1 2 3 } 1 swap nth-end ] unit-test
{ 1 } [ { 1 2 3 } 2 swap nth-end ] unit-test

[ { 1 2 3 } -1 swap nth-end ] [ bounds-error? ] must-fail-with
[ { 1 2 3 } 3 swap nth-end ] [ bounds-error? ] must-fail-with
[ { 1 2 3 } 4 swap nth-end ] [ bounds-error? ] must-fail-with

{ { 0 0 1 } } [ { 0 0 0 } dup 1 0 rot set-nth-end ] unit-test
{ { 0 2 0 } } [ { 0 0 0 } dup 2 1 rot set-nth-end ] unit-test
{ { 3 0 0 } } [ { 0 0 0 } dup 3 2 rot set-nth-end ] unit-test

[ { 0 0 0 } dup 1 -1 rot set-nth-end ] [ bounds-error? ] must-fail-with
[ { 0 0 0 } dup 2 3 rot set-nth-end ] [ bounds-error? ] must-fail-with
[ { 0 0 0 } dup 3 4 rot set-nth-end ] [ bounds-error? ] must-fail-with

! constructors

{ {
    { 5 5 }
    { 5 5 }
} } [ 2 2 5 <matrix> ] unit-test
! a matrix-matrix
{ { {
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
} {
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
} } } [ 2 3 2 2 -1 <matrix> <matrix> ] unit-test

{ {
    { 5 5 }
    { 5 5 }
} } [ 2 2 [ 5 ] <matrix-by> ] unit-test
{ {
    { 6 6 }
    { 6 6 }
} } [ 2 2 [ 3 2 * ] <matrix-by> ] unit-test

{ {
    { 0 1 2 }
    { 1 2 3 }
} } [ 2 3 [ + ] <matrix-by-indices> ] unit-test
{ {
    { 0 0 0 }
    { 0 1 2 }
    { 0 2 4 }
} } [ 3 3 [ * ] <matrix-by-indices> ] unit-test

{ t } [ 3 3 <zero-matrix> zero-square-matrix? ] unit-test
{ t } [ 3 <zero-square-matrix> zero-square-matrix? ] unit-test
{ t f } [ 3 1 <zero-matrix> [ zero-matrix? ] [ square-matrix? ] bi ] unit-test

{ {
    { 1 0 0 }
    { 0 2 0 }
    { 0 0 3 }
} } [
    { 1 2 3 } <diagonal-matrix>
] unit-test

{ {
    { -11 0 0 0 }
    { 0 -12 0 0 }
    { 0 0 -33 0 }
    { 0 0 0 -14 }
} } [ { -11 -12 -33 -14 } <diagonal-matrix> ] unit-test

{ {
    { 0 0 1 }
    { 0 2 0 }
    { 3 0 0 }
} } [ { 1 2 3 } <anti-diagonal-matrix> ] unit-test

{ {
    { 0 0 0 -11 }
    { 0 0 -12 0 }
    { 0 -33 0 0 }
    { -14 0 0 0 }
} } [ { -11 -12 -33 -14 } <anti-diagonal-matrix> ] unit-test

{ {
    { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
} } [
    3 <identity-matrix>
] unit-test

{ {
    { 2 0 0 }
    { 0 2 0 }
    { 0 0 2 }
} } [
    3 3 0 2 <eye>
] unit-test

{ {
    { 0 2 0 }
    { 0 0 2 }
    { 0 0 0 }
} } [
    3 3 1 2 <eye>
] unit-test

{ {
    { 0 0 0 0 }
    { 2 0 0 0 }
    { 0 2 0 0 }
} } [
    3 4 -1 2 <eye>
] unit-test


{ {
    { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
} } [
    3 3 0 <simple-eye>
] unit-test

{ {
    { 0 1 0 }
    { 0 0 1 }
    { 0 0 0 }
} } [
    3 3 1 <simple-eye>
] unit-test

{ {
    { 0 0 0 }
    { 1 0 0 }
    { 0 1 0 }
} } [
    3 3 -1 <simple-eye>
] unit-test

{ {
    { 1 0 0 0 }
    { 0 1 0 0 }
    { 0 0 1 0 }
} } [
    3 4 0 <simple-eye>
] unit-test

{ {
    { 0 1 0 }
    { 0 0 1 }
    { 0 0 0 }
    { 0 0 0 }
} } [
    4 3 1 <simple-eye>
] unit-test

{ {
    { 0 0 0 }
    { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
} } [
    4 3 -1 <simple-eye>
] unit-test

{ {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
    { { 3 0 } { 3 1 } { 3 2 } }
} } [ { 4 3 } <coordinate-matrix> ] unit-test

{ {
    { 0 1 }
    { 0 1 }
} } [ 2 <square-rows> ] unit-test

{ {
    { 0 0 }
    { 1 1 }
} } [ 2 <square-cols> ] unit-test

{ {
    { 5 6 }
    { 5 6 }
} } [ { 5 6 } <square-rows> ] unit-test

{ {
    { 5 5 }
    { 6 6 }
} } [ { 5 6 } <square-cols> ] unit-test

{  {
    { 1 }
} } [ {
    { 1 2 }
} <square-rows> ] unit-test

{  {
    { 1 2 }
    { 3 4 }
} } [ {
    { 1 2 5 }
    { 3 4 6 }
} <square-rows> ] unit-test

{  {
    { 1 2 }
    { 3 4 }
} } [ {
    { 1 2 }
    { 3 4 }
    { 5 6 }
} <square-rows> ] unit-test

{ {
    { 1 0 4 }
    { 0 7 0 }
    { 6 0 3 } }
} [ {
    { 1 0 0 }
    { 0 2 0 }
    { 0 0 3 }
} {
    { 0 0 4 }
    { 0 5 0 }
    { 6 0 0 }
}
    m+
] unit-test

{ {
    { 1 0 4 }
    { 0 7 0 }
    { 6 0 3 }
} } [ {
    { 1 0 0 }
    { 0 2 0 }
    { 0 0 3 }
} {
    { 0 0 -4 }
    { 0 -5 0 }
    { -6 0 0 }
}
    m-
] unit-test

{ { 3 4 } } [ { { 1 0 } { 0 1 } } { 3 4 } mdotv ] unit-test
{ { 4 3 } } [ { { 0 1 } { 1 0 } } { 3 4 } mdotv ] unit-test

{ { { 6 } } } [ { { 3 } } { { 2 } } mdot ] unit-test
{ { { 11 } } } [ { { 1 3 } } { { 5 } { 2 } } mdot ] unit-test

{ { { 28 } } } [
    { { 2 4 6 } }
    { { 1 } { 2 } { 3 } }
    mdot
] unit-test

{ 9 }
[ { { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } matrix-l1-norm ] unit-test

{ 8 }
[ { { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } matrix-l-infinity-norm ] unit-test

{ 2.0 }
[ { { 1 1 } { 1 1 } } matrix-l2-norm ] unit-test

{ 10e-8 }
[
  5.4772255
  { { 1 2 } { 3 4 } } matrix-l2-norm
] unit-test~

{ 10e-6 }
[
  36.94590
  { { 1 2 } { 4 8 } { 16 32 } } matrix-l2-norm
] unit-test~

! equivalent to frobenius for p = q = 2
{ 2.0 }
[ { { 1 1 } { 1 1 } } 2 2 matrix-p-q-norm ] unit-test

{ 10e-7 }
[
  33.456466
  { { 1 2 } { 4 8 } { 16 32 } } 3 matrix-p-norm-entrywise
] unit-test~

{ { { -1 0 } { 0 0 } } }
[ { { -2 0 } { 0 0 } } matrix-normalize ] unit-test

{ { { -1 0 } { 0 1/2 } } }
[ { { -2 0 } { 0 1 } } matrix-normalize ] unit-test

{ t }
[ 3 3 <zero-matrix> dup matrix-normalize = ] unit-test

! diagonals

! diagonal getters
{ { 1 1 1 1 } } [ 4 <identity-matrix> main-diagonal ] unit-test
{ { 0 0 0 0 } } [ 4 <identity-matrix> anti-diagonal ] unit-test
{ { 4 8 } } [ { { 4 6 } { 3 8 } } main-diagonal ] unit-test
{ { 6 3 } } [ { { 4 6 } { 3 8 } } anti-diagonal ] unit-test
{ { 1 2 3 } } [ { { 0 0 1 } { 0 2 0 } { 3 0 0 } } anti-diagonal ] unit-test
{ { 1 2 3 4 } } [ { 1 2 3 4 } <diagonal-matrix> main-diagonal ] unit-test

! transposition
{ { 1 2 3 4 } } [ { 1 2 3 4 } <diagonal-matrix> transpose main-diagonal ] unit-test
{ t } [ 50 <identity-matrix> dup transpose = ] unit-test
{ { 4 3 2 1 } } [ { 1 2 3 4 } <anti-diagonal-matrix> transpose anti-diagonal ] unit-test

{ {
  { 1 4 7 }
  { 2 5 8 }
  { 3 6 9 }
} } [ {
  { 1 2 3 }
  { 4 5 6 }
  { 7 8 9 }
} transpose ] unit-test

! anti transposition
{ { 1 2 3 4 } } [ { 1 2 3 4 } <anti-diagonal-matrix> anti-transpose anti-diagonal ] unit-test
{ t } [ 50 <iota> <anti-diagonal-matrix> dup anti-transpose = ] unit-test
{ { 4 3 2 1 } } [ { 1 2 3 4 } <diagonal-matrix> anti-transpose main-diagonal ] unit-test

{ {
  { 9 6 3 }
  { 8 5 2 }
  { 7 4 1 }
} } [ {
  { 1 2 3 }
  { 4 5 6 }
  { 7 8 9 }
} anti-transpose ] unit-test

<PRIVATE
SYMBOLS: A B C D E F G H I J K L M N O P ;
PRIVATE>
{ { {
    { E F G H }
    { I J K L }
    { M N O P }
} {
    { A B C D }
    { I J K L }
    { M N O P }
} {
    { A B C D }
    { E F G H }
    { M N O P }
} {
    { A B C D }
    { E F G H }
    { I J K L }
} } } [
    4 {
        { A B C D }
        { E F G H }
        { I J K L }
        { M N O P }
    } <repetition>
    [ rows-except ] map-index
] unit-test

{ { { 2 } } } [ { { 1 } { 2 } } 0 rows-except ] unit-test
{ { { 1 } } } [ { { 1 } { 2 } } 1 rows-except ] unit-test
{ { } } [ { { 1 } }       0 rows-except ] unit-test
{ { { 1 } } } [ { { 1 } } 1 rows-except ] unit-test
{ {
    { 2 7 12 2 } ! 0
    { 1 3 3 5 }  ! 2
} } [ {
    { 2 7 12 2 }
    { 8 9 10 0 }
    { 1 3 3 5 }
    { 8 13 7 12 }
} { 1 3 } rows-except ] unit-test

{ { {
    { B C D }
    { F G H }
    { J K L }
    { N O P }
} {
    { A C D }
    { E G H }
    { I K L }
    { M O P }
} {
    { A B D }
    { E F H }
    { I J L }
    { M N P }
} {
    { A B C }
    { E F G }
    { I J K }
    { M N O }
} } } [
    4 {
        { A B C D }
        { E F G H }
        { I J K L }
        { M N O P }
    } <repetition>
    [ cols-except ] map-index
] unit-test

{ { } } [ { { 1 } { 2 } } 0 cols-except ] unit-test
{ { { 1 } { 2 } } } [ { { 1 } { 2 } } 1 cols-except ] unit-test
{ { } } [ { { 1 } }       0 cols-except ] unit-test
{ { { 1 } } } [ { { 1 } } 1 cols-except ] unit-test
{ { { 2 } { 4 } } } [ { { 1 2 } { 3 4 } } 0 cols-except ] unit-test
{ { { 1 } { 3 } } } [ { { 1 2 } { 3 4 } } 1 cols-except ] unit-test
{ {
    { 2 12 }
    { 8 10 }
    { 1 3 }
    { 8 7 }
} } [ {
    { 2 7 12 2 }
    { 8 9 10 0 }
    { 1 3 3 5 }
    { 8 13 7 12 }
} { 1 3 } cols-except ] unit-test

{ { {
    { F G H }
    { J K L }
    { N O P }
} {
    { A C D }
    { I K L }
    { M O P }
} {
    { A B D }
    { E F H }
    { M N P }
} {
    { A B C }
    { E F G }
    { I J K }
} } } [
    4 {
        { A B C D }
        { E F G H }
        { I J K L }
        { M N O P }
    } <repetition>
    [ dup 2array matrix-except ] map-index
] unit-test

! prepare for bracket hell
! going to test the Matrix of Minors permutation strategy

! going to test 1x2 inputs
! the input had 2 elements, the output has 2 0-matrices across 2 arrays ;)
{ { { { } { } } } } [ { { 1 2 } } matrix-except-all ] unit-test

! any matrix with a 1 in its dimensions will give a void matrix output
{ t } [ { { 1 2 } }     matrix-except-all null-matrix? ] unit-test
{ t } [ { { 1 } { 2 } } matrix-except-all null-matrix? ] unit-test

! going to test 2x2 inputs
! these 1x1 output matrices have omitted a row and column from the 2x2 input

! the input had 4 elements, the output has 4 1-matrices across 2 arrays
! the permutations of indices 0 1 are: 0 0, 0 1, 1 0, 1 1
{
    { ! output array
        { ! item #1: excluding row 0...
            { { 3 } } ! and col 0 = 0 0
            { { 2 } } ! and col 1 = 0 1
        }
        { ! item #2: excluding row 1...
            { { 1 } } ! and col 0 = 1 0
            { { 0 } } ! and col 1 = 1 1
        }
    }
} [
    ! the input to the function is a simple 2x2
    { { 0 1 } { 2 3 } } matrix-except-all
] unit-test

! we are going to ensure that "duplicate" matrices are not omitted in the output
{
    {
        { ! item 1
            { { 0 } }
            { { 0 } }
        }
        { ! item 2
            { { 0 } }
            { { 0 } }
        }
    }
} [ { { 0 0 } { 0 0 } } matrix-except-all ] unit-test
! the output only has elements from the input
{ t } [ 44 <zero-square-matrix> matrix-except-all zero-matrix? ] unit-test

! going to test 2x3 and 3x2 inputs
{
    { ! output array
        { ! excluding row 0
            { { 2 } { 3 } } ! and col 0
            { { 1 } { 2 } } ! and col 1
        }
        { ! excluding row 1
            { { 1 } { 3 } } ! and col 0
            { { 0 } { 2 } } ! and col 1
        }
        { ! excluding row 2
            { { 1 } { 2 } } ! col 0
            { { 0 } { 1 } } ! col 1
        }
    }
} [ {
    { 0 1 }
    { 1 2 }
    { 2 3 }
} matrix-except-all ] unit-test

{
    { ! output array
        { ! excluding row 0
            { { 2 3 } } ! col 0
            { { 1 3 } } ! col 1
            { { 1 2 } } ! col 2
        }
        { ! row 1
            { { 1 2 } } ! col 0
            { { 0 2 } } ! col 1
            { { 0 1 } } ! col 2
        }
    }
} [ {
    { 0 1 2 }
    { 1 2 3 }
} matrix-except-all ] unit-test

! going to test 3x3 inputs

! the input had 9 elements, the output has 9 2-matrices across 3 arrays
! every element from the input is represented 4 times in the output
! the number of copies of each element found in the output is the side length of the next smaller square matrix
! 3x3 input gives 4 copies of each element; (N-1) ^ 2 = 4 where N=3
! the permutations of indices 0 1 2 are: 0 0, 0 1, 0 2; 1 0, 1 1, 1 2; 2 0, 2 1, 2 2
{
    { ! output array
        { ! item #1: excluding row 0...
            { ! and col 0 = 0 0
                { 4 5 }
                { 7 8 }
            }
            { ! and col 1 = 0 1
                { 3 5 }
                { 6 8 }
            }
            { ! and col 2 = 0 2
                { 3 4 }
                { 6 7 }
            }
        }

        { ! item #2: excluding row 1...
            { ! and col 0 = 1 0
                { 1 2 }
                { 7 8 }
            }
            { ! and col 1 = 1 1
                { 0 2 }
                { 6 8 }
            }
            { ! and col 2 = 1 2
                { 0 1 }
                { 6 7 }
            }
        }

        { ! item #2: excluding row 2...
            { ! and col 0 = 2 0
                { 1 2 }
                { 4 5 }
            }
            { ! and col 1 = 2 1
                { 0 2 }
                { 3 5 }
            }
            { ! and col 2 = 2 2
                { 0 1 }
                { 3 4 }
            }
        }
    }
    t ! note this
} [ {
    { 0 1 2 }
    { 3 4 5 }
    { 6 7 8 }
} matrix-except-all dup flatten sorted-histogram values
    { [ length 9 = ] [ [ 4 = ] all? ] }
    1&&
] unit-test

! going to test 4x4 inputs

! don't feel like handwriting this right now, so a sanity check test instead
! the input contains 4 rows and 4 columns for 16 elements
! 4x4 input gives 9 copies of each element; (N-1) ^ 2 = 9 where N = 4
{ t } [ {
    { 0 1 2 3 }
    { 4 5 6 7 }
    { 8 9 10 11 }
    { 12 13 14 15 }
} matrix-except-all flatten sorted-histogram values
    { [ length 16 = ] [ [ 9 = ] all? ] }
    1&&
] unit-test
