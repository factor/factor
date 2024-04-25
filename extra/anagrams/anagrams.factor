! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii assocs io.encodings.ascii io.files kernel math
sequences sequences.extras sets sorting system ;
IN: anagrams

: make-anagram-hash ( strings -- assoc )
    [ sort ] collect-by
    [ members ] assoc-map
    [ length 1 > ] filter-values ;

HOOK: dict-words os ( -- seq )

M: unix dict-words
    "/usr/share/dict/words" ascii file-lines [ >lower ] map ;

MEMO: dict-anagrams ( -- assoc )
    dict-words make-anagram-hash ;

: anagrams ( str -- seq/f )
    >lower sort dict-anagrams at ;

: most-anagrams ( -- seq )
    dict-anagrams values all-longest ;

: longest-anagrams ( -- seq )
    dict-anagrams [ keys all-longest ] keep '[ _ at ] map ;
