! The Porter Stemming Algorithm, hand translated to Factor from
! Common Lisp by Slava Pestov.

! The Common Lisp version was hand translated from ANSI C by
! Steven M. Haflich smh@franz.com.

! The original ANSI C was written by Martin Porter.

! References:
!   http://www.tartarus.org/~martin/PorterStemmer
!   Porter, 1980, An algorithm for suffix stripping, Program,
!   Vol. 14, no. 3, pp 130-137.
IN: porter-stemmer
USING: kernel math parser sequences ;

: consonant? ( i str -- ? )
    2dup nth dup "aeiou" member? [
        3drop f
    ] [
        CHAR: y = [
            over zero?
            [ 2drop t ] [ >r 1- r> consonant? not ] if
        ] [
            2drop t
        ] if
    ] if ;

: skip-vowels ( i str -- i str )
    2dup bounds-check? [
        2dup consonant? [ >r 1+ r> skip-vowels ] unless
    ] when ;

: skip-consonants ( i str -- i str )
    2dup bounds-check? [
        2dup consonant? [ >r 1+ r> skip-consonants ] when
    ] when ;

: (consonant-seq) ( n i str -- n )
    skip-vowels
    2dup bounds-check? [
        >r 1+ >r 1+ r> r> skip-consonants >r 1+ r>
        (consonant-seq)
    ] [
        2drop
    ] if ;

: consonant-seq ( str -- n )
    0 0 rot skip-consonants (consonant-seq) ;

: stem-vowel? ( str -- ? )
    dup length [ swap consonant? ] all-with? not ;

: double-consonant? ( i str -- ? )
    over 1 < [
        2drop f
    ] [
        2dup nth >r over 1- over nth r> = [
            consonant?
        ] [
            2drop f
        ] if
    ] if ;

: consonant-end? ( n seq -- ? )
    [ length swap - ] keep consonant? ;

: last-is? ( str possibilities -- ? ) >r peek r> member? ;

: cvc? ( str -- ? )
    {
        { [ dup length 3 < ] [ drop f ] }
        { [ 1 over consonant-end? not ] [ drop f ] }
        { [ 2 over consonant-end? ] [ drop f ] }
        { [ 3 over consonant-end? not ] [ drop f ] }
        { [ t ] [ "wxy" last-is? not ] }
    } cond ;

: r ( str oldsuffix newsuffix -- str )
    pick consonant-seq 0 > [ nip ] [ drop ] if append ;

: butlast ( seq -- seq ) 1 swap head-slice* ;

! step1a and step1b get rid of plurals and -ed or -ing. e.g.
!
!     caresses  ->  caress
!     ponies    ->  poni
!     ties      ->  ti
!     caress    ->  caress
!     cats      ->  cat
!
!     feed      ->  feed
!     agreed    ->  agree
!     disabled  ->  disable
!
!     matting   ->  mat
!     mating    ->  mate
!     meeting   ->  meet
!     milling   ->  mill
!     messing   ->  mess
!
!     meetings  ->  meet

: step1a ( str -- str )
    dup peek CHAR: s = [
        {
            { [ "sses" ?tail ] [ "ss" append ] }
            { [ "ies" ?tail ] [ "i" append ] }
            { [ dup "ss" tail? ] [ ] }
            { [ "s" ?tail ] [ ] }
            { [ t ] [ ] }
        } cond
    ] when ;

: -eed ( str -- str )
    dup consonant-seq 0 > "ee" "eed" ? append ;

: -ed ( str -- str ? )
    dup stem-vowel? [ [ "ed" append ] unless ] keep ;

: -ing ( str -- str ? )
    dup stem-vowel? [ [ "ing" append ] unless ] keep ;

: -ed/ing ( str -- str )
    {
        { [ "at" ?tail ] [ "ate" append ] }
        { [ "bl" ?tail ] [ "ble" append ] }
        { [ "iz" ?tail ] [ "ize" append ] }
        {
            [ dup length 1- over double-consonant? ]
            [ dup "lsz" last-is? [ butlast ] unless ]
        }
        {
            [ t ]
            [
                dup consonant-seq 1 = over cvc? and
                [ "e" append ] when
            ]
        }
    } cond ;

: step1b ( str -- str ? )
    {
        { [ "eed" ?tail ] [ -eed ] }
        {
            [
                {
                    { [ "ed" ?tail ] [ -ed ] }
                    { [ "ing" ?tail ] [ -ing ] }
                    { [ t ] [ f ] }
                } cond
            ] [ -ed/ing ]
        }
        { [ t ] [ ] }
    } cond ;

: step1c ( str -- str )
    #! step1c turns terminal y to i when there is another vowel
    #! in the stem.
    dup butlast stem-vowel? [
        "y" ?tail [ "i" append ] when
    ] when ;

: step2 ( str -- str )
    #! step2 maps double suffices to single ones. so -ization
    #! ( = -ize plus-ation) maps to -ize etc. note that the
    #! string before the suffix must give consonant-seq > 0.
    {
        { [ "ational" ?tail ] [ "ational" "ate"  r ] }
        { [ "tional"  ?tail ] [ "tional"  "tion" r ] }
        { [ "enci"    ?tail ] [ "enci"    "ence" r ] }
        { [ "anci"    ?tail ] [ "anci"    "ance" r ] }
        { [ "izer"    ?tail ] [ "izer"    "ize"  r ] }
        { [ "bli"     ?tail ] [ "bli"     "ble"  r ] }
        { [ "alli"    ?tail ] [ "alli"    "al"   r ] }
        { [ "entli"   ?tail ] [ "entli"   "ent"  r ] }
        { [ "eli"     ?tail ] [ "eli"     "e"    r ] }
        { [ "ousli"   ?tail ] [ "ousli"   "ous"  r ] }
        { [ "ization" ?tail ] [ "ization" "ize"  r ] }
        { [ "ation"   ?tail ] [ "ation"   "ate"  r ] }
        { [ "ator"    ?tail ] [ "ator"    "ate"  r ] }
        { [ "alism"   ?tail ] [ "alism"   "al"   r ] }
        { [ "iveness" ?tail ] [ "iveness" "ive"  r ] }
        { [ "fulness" ?tail ] [ "fulness" "ful"  r ] }
        { [ "ousness" ?tail ] [ "ousness" "ous"  r ] }
        { [ "aliti"   ?tail ] [ "aliti"   "al"   r ] }
        { [ "iviti"   ?tail ] [ "iviti"   "ive"  r ] }
        { [ "biliti"  ?tail ] [ "biliti"  "ble"  r ] }
        { [ "logi"    ?tail ] [ "logi"    "log"  r ] }
        { [ t ] [ ] }
    } cond ;

: step3 ( str -- str )
    #! step3 deals with -ic-, -full, -ness etc. similar
    #! jstrategy to step2.
    {
        { [ "icate" ?tail ] [ "icate" "ic" r ] }
        { [ "ative" ?tail ] [ "ative" ""   r ] }
        { [ "alize" ?tail ] [ "alize" "al" r ] }
        { [ "iciti" ?tail ] [ "iciti" "ic" r ] }
        { [ "ical"  ?tail ] [ "ical"  "ic" r ] }
        { [ "ful"   ?tail ] [ "ful"   ""   r ] }
        { [ "ness"  ?tail ] [ "ness"  ""   r ] }
        { [ t ] [ ] }
    } cond ;

: -ion ( str -- str )
    dup empty? [
        drop "ion"
    ] [
        dup "st" last-is? [ "ion" append ] unless
    ] if ;

: step4 ( str -- str )
    dup {
        { [ "al"    ?tail ] [ ] }
        { [ "ance"  ?tail ] [ ] }
        { [ "ence"  ?tail ] [ ] }
        { [ "er"    ?tail ] [ ] }
        { [ "ic"    ?tail ] [ ] }
        { [ "able"  ?tail ] [ ] }
        { [ "ible"  ?tail ] [ ] }
        { [ "ant"   ?tail ] [ ] }
        { [ "ement" ?tail ] [ ] }
        { [ "ment"  ?tail ] [ ] }
        { [ "ent"   ?tail ] [ ] }
        { [ "ion"   ?tail ] [ -ion ] }
        { [ "ou"    ?tail ] [ ] }
        { [ "ism"   ?tail ] [ ] }
        { [ "ate"   ?tail ] [ ] }
        { [ "iti"   ?tail ] [ ] }
        { [ "ous"   ?tail ] [ ] }
        { [ "ive"   ?tail ] [ ] }
        { [ "ize"   ?tail ] [ ] }
        { [ t ] [ ] }
    } cond dup consonant-seq 1 > [ nip ] [ drop ] if ;

: remove-e? ( str -- ? )
    dup consonant-seq dup 1 >
    [ 2drop t ]
    [ 1 = [ butlast cvc? not ] [ drop f ] if ] if ;

: remove-e ( str -- str )
    #! removes a final -e if consonant-seq > 1
    dup peek CHAR: e = [
        dup remove-e? [ butlast ] when
    ] when ;

: ll->l ( str -- str )
    #! changes -ll to -l if consonant-seq > 1.
    {
        { [ dup peek CHAR: l = not ] [ ] }
        { [ dup length 1- over double-consonant? not ] [ ] }
        { [ dup consonant-seq 1 > ] [ butlast ] }
        { [ t ] [ ] }
    } cond ;

: step5 ( str -- str ) remove-e ll->l ;

: stem ( str -- str )
    dup length 2 <= [
        step1a step1b step1c step2 step3 step4 step5 "" like
    ] unless ;
