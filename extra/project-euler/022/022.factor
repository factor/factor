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

: (source-022) ( -- path )
    [
        "project-euler.022" vocab-root ?resource-path %
        os "windows" = [
            "\\project-euler\\022\\names.txt" %
        ] [
            "/project-euler/022/names.txt" %
        ] if
    ] "" make ;

: source-022 ( -- seq )
    (source-022) <file-reader> contents [ quotable? ] subset "," split ;

: alpha-value ( str -- n )
    string>digits [ 9 - ] sigma ;

: name-score ( str seq -- n )
    over alpha-value -rot index 1+ * ;

PRIVATE>

: euler022 ( -- answer )
    source-022 natural-sort dup [ over name-score ] sigma nip ;

! [ euler022 ] 100 ave-time
! 906 ms run / 1 ms GC ave time - 100 trials

! source-022 [ natural-sort dup [ over name-score ] sigma nip ] curry 100 ave-time
! 850 ms run / 0 ms GC ave time - 100 trials


! ALTERNATE SOLUTIONS
! -------------------

! Take advantage of the names being ordered and eliminate calls to name-score

: euler022a ( -- answer )
    source-022 natural-sort dup length [ 1+ swap alpha-value * ] 2map sum ;

! [ euler022 ] 100 ave-time
! 60 ms run / 1 ms GC ave time - 100 trials

! source-022 [ natural-sort dup length [ 1+ swap alpha-value * ] 2map sum ] curry 100 ave-time
! 47 ms run / 1 ms GC ave time - 100 trials

MAIN: euler022a
