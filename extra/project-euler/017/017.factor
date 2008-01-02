! Copyright (c) 2007 Samuel Tardieu, Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib kernel math math.ranges math.text namespaces sequences
    strings ;
IN: project-euler.017

! http://projecteuler.net/index.php?section=problems&id=17

! DESCRIPTION
! -----------

! If the numbers 1 to 5 are written out in words: one, two, three, four, five;
! there are 3 + 3 + 5 + 4 + 4 = 19 letters used in total.

! If all the numbers from 1 to 1000 (one thousand) inclusive were written out
! in words, how many letters would be used?

! NOTE: Do not count spaces or hyphens. For example, 342 (three hundred and
! forty-two) contains 23 letters and 115 (one hundred and fifteen) contains
! 20 letters.


! SOLUTION
! --------

<PRIVATE

: units ( n -- )
  {
    "zero" "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"
    "ten" "eleven" "twelve" "thirteen" "fourteen" "fifteen" "sixteen"
    "seventeen" "eighteen" "nineteen"
  } nth % ;

: tenths ( n -- )
  {
    f f "twenty" "thirty" "fourty" "fifty" "sixty" "seventy" "eighty" "ninety"
  } nth % ;

DEFER: make-english

: maybe-add ( n sep -- )
  over zero? [ 2drop ] [ % make-english ] if ;

: 0-99 ( n -- )
  dup 20 < [ units ] [ 10 /mod swap tenths "-" maybe-add ] if ;

: 0-999 ( n -- )
  100 /mod swap
  dup zero? [ drop 0-99 ] [ units " hundred" % " and " maybe-add ] if ;

: make-english ( n -- )
  1000 /mod swap
  dup zero? [ drop 0-999 ] [ 0-999 " thousand" % " and " maybe-add ] if ;

PRIVATE>

: >english ( n -- str )
  [ make-english ] "" make ;

: euler017 ( -- answer )
  1000 [1,b] [ >english [ letter? ] subset length ] map sum ;

! [ euler017 ] 100 ave-time
! 9 ms run / 0 ms GC ave time - 100 trials


! ALTERNATE SOLUTIONS
! -------------------

: euler017a ( -- answer )
    1000 [1,b] SBUF" " clone [ number>text over push-all ] reduce [ Letter? ] count ;

! [ euler017a ] 100 ave-time
! 14 ms run / 1 ms GC ave time - 100 trials

MAIN: euler017
