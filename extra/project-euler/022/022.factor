! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib io io.files kernel math math.parser namespaces sequences
    sorting splitting strings system vocabs ;
IN: project-euler.022

! http://projecteuler.net/index.php?section=problems&id=22

! DESCRIPTION
! -----------

! Using names.txt (right click and 'Save Link/Target As...'), a 46K text file
! containing over five-thousand first names, begin by sorting it into
! alphabetical order. Then working out the alphabetical value for each name,
! multiply this value by its alphabetical position in the list to obtain a name
! score.

! For example, when the list is sorted into alphabetical order, COLIN, which is
! worth 3 + 15 + 12 + 9 + 14 = 53, is the 938th name in the list. So, COLIN
! would obtain a score of 938 * 53 = 49714.

! What is the total of all the name scores in the file?


! SOLUTION
! --------

<PRIVATE

: source-022 ( -- seq )
    "extra/project-euler/022/names.txt" resource-path
    file-contents [ quotable? ] subset "," split ;

: alpha-value ( str -- n )
    string>digits [ 9 - ] sigma ;

: name-scores ( seq -- seq )
    dup length [ 1+ swap alpha-value * ] 2map ;

PRIVATE>

: euler022 ( -- answer )
    source-022 natural-sort name-scores sum ;

! [ euler022 ] 100 ave-time
! 59 ms run / 1 ms GC ave time - 100 trials

! source-022 [ natural-sort name-scores sum ] curry 100 ave-time
! 45 ms run / 1 ms GC ave time - 100 trials

MAIN: euler022
