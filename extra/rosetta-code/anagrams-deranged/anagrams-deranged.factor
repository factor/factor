! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: assocs http.client io.encodings.utf8 io.files
io.files.temp kernel math math.combinatorics sequences sorting
strings urls ;

IN: rosettacode.anagrams-deranged

! https://rosettacode.org/wiki/Anagrams/Deranged_anagrams

! Two or more words are said to be anagrams if they have the
! same characters, but in a different order. By analogy with
! derangements we define a deranged anagram as two words with the
! same characters, but in which the same character does not appear
! in the same position in both words.

! The task is to use the word list at
! https://www.puzzlers.org/pub/wordlists/unixdict.txt to find and
! show the longest deranged anagram.

: derangement? ( str1 str2 -- ? ) [ = not ] 2all? ;

: derangements ( seq -- seq )
    2 [ first2 derangement? ] filter-combinations ;

: parse-dict-file ( path -- hash )
    utf8 file-lines
    H{ } clone [
        '[
            [ sort >string ] keep
            _ [ swap suffix  ] with change-at
        ] each
    ] keep ;

: anagrams ( hash -- seq ) [ length 1 > ] filter-values values ;

: deranged-anagrams ( path -- seq )
    parse-dict-file anagrams [ derangements ] map concat ;

: (longest-deranged-anagrams) ( path -- anagrams )
    deranged-anagrams [ first length ] sort-by last ;

: default-word-list ( -- path )
    URL" https://puzzlers.org/pub/wordlists/unixdict.txt"
    "unixdict.txt" temp-file [ ?download-to ] keep ;

: longest-deranged-anagrams ( -- anagrams )
    default-word-list (longest-deranged-anagrams) ;
