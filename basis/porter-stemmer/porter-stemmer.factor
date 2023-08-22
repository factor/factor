USING: combinators english kernel math parser sequences
splitting ;
IN: porter-stemmer

: consonant? ( i str -- ? )
    2dup nth dup vowel? [
        3drop f
    ] [
        CHAR: y = [
            over zero?
            [ 2drop t ] [ [ 1 - ] dip consonant? not ] if
        ] [
            2drop t
        ] if
    ] if ;

: skip-vowels ( i str -- i str )
    2dup bounds-check? [
        2dup consonant? [ [ 1 + ] dip skip-vowels ] unless
    ] when ;

: skip-consonants ( i str -- i str )
    2dup bounds-check? [
        2dup consonant? [ [ 1 + ] dip skip-consonants ] when
    ] when ;

: (consonant-seq) ( n i str -- n )
    skip-vowels
    2dup bounds-check? [
        [ 1 + ] [ 1 + ] [ ] tri* skip-consonants [ 1 + ] dip
        (consonant-seq)
    ] [
        2drop
    ] if ;

: consonant-seq ( str -- n )
    [ 0 0 ] dip skip-consonants (consonant-seq) ;

: stem-vowel? ( str -- ? )
    [ length <iota> ] keep [ consonant? ] curry all? not ;

: double-consonant? ( i str -- ? )
    over 1 < [
        2drop f
    ] [
        2dup nth [ over 1 - over nth ] dip = [
            consonant?
        ] [
            2drop f
        ] if
    ] if ;

: consonant-end? ( n seq -- ? )
    [ length swap - ] keep consonant? ;

: last-is? ( str possibilities -- ? ) [ last ] dip member? ;

: cvc? ( str -- ? )
    {
        { [ dup length 3 < ] [ drop f ] }
        { [ 1 over consonant-end? not ] [ drop f ] }
        { [ 2 over consonant-end? ] [ drop f ] }
        { [ 3 over consonant-end? not ] [ drop f ] }
        [ "wxy" last-is? not ]
    } cond ;

: r ( str oldsuffix newsuffix -- str )
    pick consonant-seq 0 > [ nip ] [ drop ] if append ;

: step1a ( str -- newstr )
    dup last CHAR: s = [
        {
            { [ "sses" ?tail ] [ "ss" append ] }
            { [ "ies" ?tail ] [ "i" append ] }
            { [ dup "ss" tail? ] [ ] }
            { [ "s" ?tail ] [ ] }
            [ ]
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
            [ dup length 1 - over double-consonant? ]
            [ dup "lsz" last-is? [ but-last-slice ] unless ]
        }
        {
            [ t ]
            [
                dup consonant-seq 1 = over cvc? and
                [ "e" append ] when
            ]
        }
    } cond ;

: step1b ( str -- newstr )
    {
        { [ "eed" ?tail ] [ -eed ] }
        {
            [
                {
                    { [ "ed" ?tail ] [ -ed ] }
                    { [ "ing" ?tail ] [ -ing ] }
                    [ f ]
                } cond
            ] [ -ed/ing ]
        }
        [ ]
    } cond ;

: step1c ( str -- newstr )
    dup but-last-slice stem-vowel? [
        "y" ?tail [ "i" append ] when
    ] when ;

: step2 ( str -- newstr )
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
        [ ]
    } cond ;

: step3 ( str -- newstr )
    {
        { [ "icate" ?tail ] [ "icate" "ic" r ] }
        { [ "ative" ?tail ] [ "ative" ""   r ] }
        { [ "alize" ?tail ] [ "alize" "al" r ] }
        { [ "iciti" ?tail ] [ "iciti" "ic" r ] }
        { [ "ical"  ?tail ] [ "ical"  "ic" r ] }
        { [ "ful"   ?tail ] [ "ful"   ""   r ] }
        { [ "ness"  ?tail ] [ "ness"  ""   r ] }
        [ ]
    } cond ;

: -ion ( str -- newstr )
    [
        "ion"
    ] [
        dup "st" last-is? [ "ion" append ] unless
    ] if-empty ;

: step4 ( str -- newstr )
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
        [ ]
    } cond dup consonant-seq 1 > [ nip ] [ drop ] if ;

: remove-e? ( str -- ? )
    dup consonant-seq dup 1 >
    [ 2drop t ]
    [ 1 = [ but-last-slice cvc? not ] [ drop f ] if ] if ;

: remove-e ( str -- newstr )
    dup last CHAR: e = [
        dup remove-e? [ but-last-slice ] when
    ] when ;

: ll->l ( str -- newstr )
    {
        { [ dup last CHAR: l = not ] [ ] }
        { [ dup length 1 - over double-consonant? not ] [ ] }
        { [ dup consonant-seq 1 > ] [ but-last-slice ] }
        [ ]
    } cond ;

: step5 ( str -- newstr ) remove-e ll->l ;

: stem ( str -- newstr )
    dup length 2 <= [
        step1a step1b step1c step2 step3 step4 step5 "" like
    ] unless ;
