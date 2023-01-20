! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.ascii io.files kernel math math.functions
math.parser math.vectors project-euler.common sequences
sequences.extras splitting ;
IN: project-euler.099

! https://projecteuler.net/index.php?section=problems&id=99

! DESCRIPTION
! -----------

! Comparing two numbers written in index form like 2^11 and 3^7 is not difficult,
! as any calculator would confirm that 2^11 = 2048 < 3^7 = 2187.

! However, confirming that 632382^518061 519432^525806 would be much more
! difficult, as both numbers contain over three million digits.

! Using base_exp.txt (right click and 'Save Link/Target As...'), a 22K text
! file containing one thousand lines with a base/exponent pair on each line,
! determine which line number has the greatest numerical value.

! NOTE: The first two lines in the file represent the numbers in the example
! given above.


! SOLUTION
! --------

! Use logarithms to make the calculations necessary more manageable.

<PRIVATE

: source-099 ( -- seq )
    "resource:extra/project-euler/099/base_exp.txt"
    ascii file-lines [ "," split [ string>number ] map ] map ;

: simplify ( seq -- seq )
    ! exponent * log(base)
    flip first2 swap [ log ] map v* ;

: solve ( seq -- index )
    simplify arg-max 1 + ;

PRIVATE>

: euler099 ( -- answer )
    source-099 solve ;

! [ euler099 ] 100 ave-time
! 16 ms ave run timen - 1.67 SD (100 trials)

SOLUTION: euler099
