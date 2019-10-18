! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii assocs fry io.encodings.ascii io.files kernel math
memoize sequences sequences.extras sorting sets ;
IN: anagrams

: make-anagram-hash ( strings -- assoc )
    [ natural-sort ] collect-by
    [ members ] assoc-map
    [ nip length 1 > ] assoc-filter ;

MEMO: dict-words ( -- seq )
    "/usr/share/dict/words" ascii file-lines [ >lower ] map ;

MEMO: dict-anagrams ( -- assoc )
    dict-words make-anagram-hash ;

: anagrams ( str -- seq/f )
    >lower natural-sort dict-anagrams at ;

: most-anagrams ( -- seq )
    dict-anagrams values all-longest ;

: longest-anagrams ( -- seq )
    dict-anagrams [ keys all-longest ] keep '[ _ at ] map ;
