! Copyright (c) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.ascii io.files kernel math
project-euler.common roman sequences ;
IN: project-euler.089

! https://projecteuler.net/index.php?section=problems&id=089

! DESCRIPTION
! -----------

! The rules for writing Roman numerals allow for many ways of writing
! each number (see FAQ: Roman Numerals). However, there is always a
! "best" way of writing a particular number.

! For example, the following represent all of the legitimate ways of
! writing the number sixteen:

! IIIIIIIIIIIIIIII
! VIIIIIIIIIII
! VVIIIIII
! XIIIIII
! VVVI
! XVI

! The last example being considered the most efficient, as it uses
! the least number of numerals.

! The 11K text file, roman.txt (right click and 'Save Link/Target As...'),
! contains one thousand numbers written in valid, but not necessarily
! minimal, Roman numerals; that is, they are arranged in descending units
! and obey the subtractive pair rule (see FAQ for the definitive rules
! for this problem).

! Find the number of characters saved by writing each of these in their minimal form.

! SOLUTION
! --------

: euler089 ( -- n )
    "resource:extra/project-euler/089/roman.txt" ascii file-lines
    [ ] [ [ roman> >roman ] map ] bi
    [ [ length ] map-sum ] bi@ - ;

! [ euler089 ] 100 ave-time
! 14 ms ave run time - 0.27 SD (100 trials)

SOLUTION: euler089
