! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: grouping http.download io io.encodings.utf8 io.files
io.files.temp math sequences sequences.extras unicode urls ;
IN: rosetta-code.ordered-words

! https://rosettacode.org/wiki/Ordered_words

! Define an ordered word as a word in which the letters of the
! word appear in alphabetic order. Examples include 'abbey' and
! 'dirt'.

! The task is to find and display all the ordered words in this
! dictionary that have the longest word length. (Examples that
! access the dictionary file locally assume that you have
! downloaded this file yourself.) The display needs to be shown on
! this page.

MEMO: word-list ( -- seq )
    URL" https://raw.githubusercontent.com/quinnj/Rosetta-Julia/master/unixdict.txt"
    "unixdict.txt" temp-file
    download-once-as utf8 file-lines ;

: ordered-word? ( word -- ? )
    >lower [ <= ] monotonic? ;

: ordered-words-main ( -- )
    word-list [ ordered-word? ] filter
    all-longest [ print ] each ;

MAIN: ordered-words-main
