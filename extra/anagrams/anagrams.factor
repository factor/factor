! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays ascii assocs fry io.encodings.ascii io.files
kernel math math.order memoize sequences sorting ;

IN: anagrams

: (all-anagrams) ( seq assoc -- )
    '[ dup natural-sort _ push-at ] each ;

: all-anagrams ( seq -- assoc )
    H{ } clone [ (all-anagrams) ] keep
    [ nip length 1 > ] assoc-filter ;

MEMO: dict-words ( -- seq )
    "/usr/share/dict/words" ascii file-lines [ >lower ] map ;

MEMO: dict-anagrams ( -- assoc )
    dict-words all-anagrams ;

: anagrams ( str -- seq/f )
    >lower natural-sort dict-anagrams at ;

: longest ( seq -- subseq )
    dup 0 [ length max ] reduce '[ length _ = ] filter ;

: most-anagrams ( -- seq )
    dict-anagrams values longest ;

: longest-anagrams ( -- seq )
    dict-anagrams [ keys longest ] keep '[ _ at ] map ;



