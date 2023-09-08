! Copyright (c) 2007 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii io.encodings.ascii io.files kernel math
project-euler.common sequences sorting splitting ;
IN: project-euler.022

! https://projecteuler.net/problem=22

! DESCRIPTION
! -----------

! Using names.txt (right click and 'Save Link/Target As...'), a
! 46K text file containing over five-thousand first names, begin
! by sorting it into alphabetical order. Then working out the
! alphabetical value for each name, multiply this value by its
! alphabetical position in the list to obtain a name score.

! For example, when the list is sorted into alphabetical order,
! COLIN, which is worth 3 + 15 + 12 + 9 + 14 = 53, is the 938th
! name in the list. So, COLIN would obtain a score of 938 * 53 =
! 49714.

! What is the total of all the name scores in the file?


! SOLUTION
! --------

<PRIVATE

: source-022 ( -- seq )
    "resource:extra/project-euler/022/names.txt"
    ascii file-contents [ quotable? ] filter "," split ;

: name-scores ( seq -- seq )
    [ 1 + swap alpha-value * ] map-index ;

PRIVATE>

: euler022 ( -- answer )
    source-022 sort name-scores sum ;

! [ euler022 ] 100 ave-time
! 74 ms ave run time - 5.13 SD (100 trials)

SOLUTION: euler022
