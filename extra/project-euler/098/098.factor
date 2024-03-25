! Copyright (c) 2023 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: anagrams assocs combinators.short-circuit http.client
io.encodings.utf8 io.files io.files.temp kernel math
math.combinatorics math.functions math.order math.parser
project-euler.common ranges sequences splitting ;

IN: project-euler.098

! https://projecteuler.net/problem=98

! DESCRIPTION
! -----------

! By replacing each of the letters in the word CARE with 1, 2, 9,
! and 6 respectively, we form a square number: 1296 = 36^2. What
! is remarkable is that, by using the same digital substitutions,
! the anagram, RACE, also forms a square number: 9216 = 96^2. We
! shall call CARE (and RACE) a square anagram word pair and
! specify further that leading zeroes are not permitted, neither
! may a different letter have the same digital value as another
! letter.

! Using words.txt (right click and 'Save Link/Target As...'), a
! 16K text file containing nearly two-thousand common English
! words, find all the square anagram word pairs (a palindromic
! word is NOT considered to be an anagram of itself).

! What is the largest square number formed by any member of such
! a pair?

! NOTE: All anagrams formed must be contained in the given text
! file.

! SOLUTION
! --------

: make-anagrams ( seq -- assoc )
    make-anagram-hash values [ 2 all-combinations ] map concat
    [ first length ] collect-by ;

: wordlist ( -- seq )
    "https://projecteuler.net/project/resources/p098_words.txt"
    "p098_words.txt" temp-file download-once-to
    utf8 file-contents "," split [ rest-slice but-last ] map ;

: squarelist ( n -- seq )
    1 + 10^ sqrt [1..b] [ sq number>string ] map ;

:: square-anagram ( word1 word2 num1 num2 -- n/f )
    {
        [ num1 num2 word2 zip substitute word1 = ]
        [ num2 num1 word1 zip substitute word2 = ]
        [ word1 word2 num2 zip substitute num1 = ]
        [ word2 word1 num1 zip substitute num2 = ]
    } 0&& [ num1 num2 [ string>number ] bi@ max ] [ f ] if ;

:: euler098 ( -- answer )
    wordlist make-anagrams :> words
    words keys maximum :> n
    n squarelist make-anagrams :> squares

    0 n [1..b] [| i |
        words i of :> w
        squares i of :> s
        w s and [
            w s [
                [ first2 ] bi@ square-anagram [ max ] when*
            ] cartesian-each
        ] when
    ] each ;

SOLUTION: euler098
