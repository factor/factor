! Copyright (c) 2012 Anonymous
! See http://factorcode.org/license.txt for BSD license.
USING: fry grouping http.client io io.encodings.utf8 io.files
io.files.temp kernel math math.order memoize sequences
unicode.case urls ;
IN: rosetta-code.ordered-words

! http://rosettacode.org/wiki/Ordered_words

! Define an ordered word as a word in which the letters of the
! word appear in alphabetic order. Examples include 'abbey' and
! 'dirt'.

! The task is to find and display all the ordered words in this
! dictionary that have the longest word length. (Examples that
! access the dictionary file locally assume that you have
! downloaded this file yourself.) The display needs to be shown on
! this page.

MEMO: word-list ( -- seq )
    "unixdict.txt" temp-file dup exists? [
        URL" http://puzzlers.org/pub/wordlists/unixdict.txt"
        over download-to
    ] unless utf8 file-lines ;

: ordered-word? ( word -- ? )
    >lower 2 <clumps> [ first2 <= ] all? ;

: filter-longest-words ( seq -- seq' )
    dup [ length ] [ max ] map-reduce
    '[ length _ = ] filter ;

: ordered-words-main ( -- )
    word-list [ ordered-word? ] filter
    filter-longest-words [ print ] each ;

MAIN: ordered-words-main
