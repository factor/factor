USING: kernel hashtables sequences io arrays math 
    hash2 namespaces strings assocs words splitting sequences.next
    byte-arrays quotations sequences.private io.files bit-arrays
    combinators math.parser io.streams.lines parser classes
    classes.predicate ;
IN: unicode

! Convenience functions
: >set ( seq -- hash )
    [ dup ] H{ } map>assoc ;

: either ( object first second -- ? )
    >r over slip swap [ r> drop ] [ r> call ] ?if ; inline

: 1+* ( n/f _ -- n+1 )
    drop [ 1+ ] [ 0 ] if* ;

: define-value ( value word -- )
    swap 1quotation define-compound ;

: ?between? ( n/f from to -- ? )
    pick [ between? ] [ 3drop f ] if ;

: range ( from to -- seq )
    1+ over - [ + ] curry* map ;

! Loading data from UnicodeData.txt

: data ( filename -- data )
    <file-reader> lines [ ";" split ] map ;

: load-data ( -- data )
    "extra/unicode/UnicodeData.txt" resource-path data ;

: (process-data) ( index data -- newdata )
    [ [ nth ] keep first swap 2array ] curry* map
    [ second empty? not ] subset
    [ >r hex> r> ] assoc-map ;

: process-data ( index data -- hash )
    (process-data) [ hex> ] assoc-map >hashtable ;

: (chain-decomposed) ( hash value -- newvalue )
    [
        2dup swap at
        [ (chain-decomposed) ] [ 1array nip ] ?if
    ] curry* map concat ;

: chain-decomposed ( hash -- newhash )
    dup [ swap (chain-decomposed) ] curry assoc-map ;

: first* ( seq -- ? )
    second [ empty? ] [ first ] either ;

: (process-decomposed) ( data -- alist )
    5 swap (process-data)
    [ " " split [ hex> ] map ] assoc-map ;

: process-canonical ( data -- hash2 hash )
    (process-decomposed) [ first* ] subset
    [
        [ second length 2 = ] subset
        ! using 1009 as the size, the maximum load is 4
        [ first2 first2 rot 3array ] map 1009 alist>hash2
    ] keep
    >hashtable chain-decomposed ;

: process-compat ( data -- hash )
    (process-decomposed)
    [ dup first* [ first2 1 tail 2array ] unless ] map
    >hashtable chain-decomposed ;

: process-combining ( data -- hash )
    3 swap (process-data)
    [ string>number ] assoc-map
    [ nip 0 = not ] assoc-subset
    >hashtable ;

: categories ( -- names )
    ! For non-existent characters, use Cn
    { "Lu" "Ll" "Lt" "Lm" "Lo"
      "Mn" "Mc" "Me"
      "Nd" "Nl" "No"
      "Pc" "Pd" "Ps" "Pe" "Pi" "Pf" "Po"
      "Sm" "Sc" "Sk" "So"
      "Zs" "Zl" "Zp"
      "Cc" "Cf" "Cs" "Co" "Cn" } ;

: unicode-chars HEX: 2FA1E ;
! the maximum unicode char in the first 3 planes

: process-category ( data -- category-listing )
    2 swap (process-data)
    unicode-chars <byte-array> swap dupd swap [
        >r over unicode-chars >= [ r> 3drop ]
        [ categories index swap r> set-nth ] if
    ] curry assoc-each ;

: ascii-lower ( string -- lower )
    [ dup CHAR: A CHAR: Z between? [ HEX: 20 + ] when ] map ;

: replace ( seq old new -- newseq )
    swap rot [ 2dup = [ drop over ] when ] map 2nip ;

: process-names ( data -- names-hash )
    1 swap (process-data)
    [ ascii-lower CHAR: \s CHAR: - replace swap ] assoc-map
    >hashtable ;

DEFER: simple-lower
DEFER: simple-upper
DEFER: simple-title
DEFER: canonical-map
DEFER: combine-map
DEFER: class-map
DEFER: compat-map
DEFER: category-map
DEFER: name-map

: load-tables ( -- )
    load-data
    dup process-names \ name-map define-value
    13 over process-data \ simple-lower define-value
    12 over process-data tuck \ simple-upper define-value
    14 over process-data swapd union \ simple-title define-value
    dup process-combining \ class-map define-value
    dup process-canonical \ canonical-map define-value
    \ combine-map define-value
    dup process-compat \ compat-map define-value
    process-category \ category-map define-value ; parsing
load-tables

: canonical-entry ( char -- seq ) canonical-map at ;
: combine-chars ( a b -- char/f ) combine-map hash2 ;
: compat-entry ( char -- seq ) compat-map at  ;
: combining-class ( char -- n ) class-map at ;
: non-starter? ( char -- ? ) class-map key? ;
: name>char ( string -- char ) name-map at ;

: UNICHAR:
    scan name>char [ parsed ] [ "Invalid character" throw ] if* ; parsing

! Character classes (categories)

: category# ( char -- category )
    ! There are a few characters that should be Cn
    ! that this gives Cf or Mn
    ! Cf = 26; Mn = 5; Cn = 29
    dup category-map ?nth [ ] [
        dup HEX: E0001 HEX: E007F between?
        [ drop 26 ] [
            HEX: E0100 HEX: E01EF between?  5 29 ?
        ] if
    ] ?if ;

: category ( char -- category )
    category# categories nth ;

: >category-array ( categories -- bitarray )
    categories [ swap member? ] curry* map >bit-array ;

: as-string ( strings -- bit-array )
    concat "\"" tuck 3append parse first ;

: [category] ( categories -- quot )
    [
        [ [ categories member? not ] subset as-string ] keep 
        [ categories member? ] subset >category-array
        [ dup category# ] % , [ nth-unsafe [ drop t ] ] %
        \ member? 2array >quotation ,
        \ if ,
    ] [ ] make ;

: define-category ( word categories -- )
    [category] fixnum -rot define-predicate-class ;

: CATEGORY:
    CREATE ";" parse-tokens define-category ; parsing

: seq-minus ( seq1 seq2 -- diff )
    [ member? not ] curry subset ;

: CATEGORY-NOT:
    CREATE ";" parse-tokens
    categories swap seq-minus define-category ; parsing

CATEGORY: blank Zs Zl Zp ;
CATEGORY: letter Ll ;
CATEGORY: LETTER Lu ;
CATEGORY: Letter Lu Ll Lt Lm Lo ;
CATEGORY: digit Nd Nl No ;
CATEGORY-NOT: printable Cc Cf Cs Co Cn ;
CATEGORY: alpha Lu Ll Lt Lm Lo Nd Nl No ;
CATEGORY: control Cc ;
CATEGORY-NOT: uncased Lu Ll Lt Lm Mn Me ; 
CATEGORY-NOT: character Cn ;

! Utility word
: make* ( seq quot exemplar -- newseq )
    ! quot has access to original seq on stack
    ! this just makes the new-resizable the same length as seq
    [
        [
            pick length swap new-resizable
            [ building set call ] keep
        ] keep like
    ] with-scope ; inline

! Case mapping

: hash-default ( key hash -- value/key )
    dupd at [ nip ] when* ;

: ch>lower ( ch -- lower ) simple-lower hash-default ;
: ch>upper ( ch -- upper ) simple-upper hash-default ;
: ch>title ( ch -- title ) simple-title hash-default ;

: load-special-data ( -- data )
    "extra/unicode/SpecialCasing.txt" resource-path data
    [ length 5 = ] subset ;

: multihex ( hexstring -- string )
    " " split [ hex> ] map [ ] subset ;

TUPLE: code-point lower title upper ;

C: <code-point> code-point

: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first set ;

DEFER: special-casing
: load-special-casing
    load-special-data [ [ set-code-point ] each ] H{ } make-assoc
    \ special-casing define-value ; parsing
load-special-casing

SYMBOL: locale ! Just casing locale, or overall?

: i-dot? ( -- ? )
    locale get { "tr" "az" } member? ;

: lithuanian? ( -- ? ) locale get "lt" = ;

: dot-over ( -- ch ) CHAR: \u0307 ;

: lithuanian-ch>upper ( ? next ch -- ? )
    rot [ 2drop f ]
    [ swap dot-over = over "ij" member? and swap , ] if ;

: lithuanian>upper ( string -- lower )
    [ f swap [ lithuanian-ch>upper ] each-next drop ] "" make* ;

: mark-above? ( ch -- ? )
    combining-class 230 = ;

: lithuanian-ch>lower ( next ch -- )
    ! This fails to add a dot above in certain edge cases
    ! where there is a non-above combining mark before an above one
    ! in Lithuanian
    dup , "IJ" member? swap mark-above? and [ dot-over , ] when ;

: lithuanian>lower ( string -- lower )
    [ [ lithuanian-ch>lower ] each-next ] "" make* ;

: turk-ch>upper ( ch -- )
    dup CHAR: i = 
    [ drop CHAR: I , dot-over , ] [ , ] if ;

: turk>upper ( string -- upper-i )
    [ [ turk-ch>upper ] each ] "" make* ;

: turk-ch>lower ( ? next ch -- ? )
    {
        { [ rot ] [ 2drop f ] }
        { [ dup CHAR: I = ] [
            drop dot-over =
            dup CHAR: i CHAR: \u0131 ? ,
        ] }
        { [ t ] [ , drop f ] }
    } cond ;

: turk>lower ( string -- lower-i )
    [ f swap [ turk-ch>lower ] each-next drop ] "" make* ;

: word-boundary ( prev char -- new ? )
    dup non-starter? [ drop dup ] when
    swap uncased? ;

: sigma-map ( string -- string )
    [
        swap [ uncased? ] keep not or
        [ drop HEX: 3C2 ] when
    ] map-next ;

: final-sigma ( string -- string )
    HEX: 3A3 over member? [ sigma-map ] when ;

: map-case ( string string-quot char-quot -- case )
    [
        rot [
            -rot [
                rot dup special-casing at
                [ -rot drop call % ]
                [ -rot nip call , ] ?if
            ] 2keep
        ] each 2drop
    ] "" make* ; inline

: >lower ( string -- lower )
    i-dot? [ turk>lower ] when
    final-sigma [ code-point-lower ] [ ch>lower ] map-case ;

: >upper ( string -- upper )
    i-dot? [ turk>upper ] when
    [ code-point-upper ] [ ch>upper ] map-case ;

: >title ( string -- title )
    final-sigma
    CHAR: \s swap
    [ tuck word-boundary swapd
        [ code-point-title ] [ code-point-lower ] if ]
    [ tuck word-boundary swapd 
        [ ch>title ] [ ch>lower ] if ]
    map-case nip ;

: >case-fold ( string -- fold )
    >upper >lower ;

: insensitive= ( str1 str2 -- ? )
    [ >case-fold ] 2apply = ;

: lower? ( string -- ? )
    dup >lower = ;
: upper? ( string -- ? )
    dup >lower = ;
: title? ( string -- ? )
    dup >title = ;
: case-fold? ( string -- ? )
    dup >case-fold = ;

! Conjoining Jamo behavior

: hangul-base HEX: ac00 ; inline
: hangul-end HEX: D7AF ; inline
: initial-base HEX: 1100 ; inline
: medial-base HEX: 1161 ; inline
: final-base HEX: 11a7 ; inline

: initial-count 19 ; inline
: medial-count 21 ; inline
: final-count 28 ; inline

: hangul? ( ch -- ? ) hangul-base hangul-end ?between? ;
: jamo? ( ch -- ? ) HEX: 1100 HEX: 11FF ?between? ;

! These numbers come from UAX 29
: initial? ( ch -- ? )
    [ HEX: 1100 HEX: 1159 ?between? ] [ HEX: 115F = ] either ;
: medial? ( ch -- ? ) HEX: 1160 HEX: 11A2 ?between? ;
: final? ( ch -- ? ) HEX: 11A8 HEX: 11F9 ?between? ;

: hangul>jamo ( hangul -- jamo-string )
    hangul-base - final-count /mod final-base +
    >r medial-count /mod medial-base +
    >r initial-base + r> r>
    dup zero? [ drop 2array ] [ 3array ] if ;

: jamo>hangul ( initial medial final -- hangul )
    >r >r initial-base - medial-count *
    r> medial-base - + final-count *
    r> final-base - + hangul-base + ;

! Normalization -- Decomposition 

: (insert) ( seq n quot -- )
    over 0 = [ 3drop ] [
        [ >r dup 1- rot [ nth ] curry 2apply r> 2apply > ] 3keep
        roll [ 3drop ]
        [ >r [ dup 1- rot exchange ] 2keep 1- r> (insert) ] if
    ] if ; inline

: insert ( seq quot elt n -- )
    swap rot >r -rot [ swap set-nth ] 2keep r> (insert) ; inline

: insertion-sort ( seq quot -- )
    ! quot is a transformation on elements
    over dup length
    [ >r >r 2dup r> r> insert ] 2each 2drop ; inline

: reorder-slice ( string start -- slice done? )
    2dup swap [ non-starter? not ] find* drop
    [ [ over length ] unless* rot <slice> ] keep not ;

: reorder-next ( string i -- new-i done? )
    over [ non-starter? ] find* drop [
        reorder-slice
        >r dup [ combining-class ] insertion-sort slice-to r>
    ] [ length t ] if* ;

: reorder-loop ( string start -- )
    dupd reorder-next [ 2drop ] [ reorder-loop ] if ;

: reorder ( string -- )
    0 reorder-loop ;

: reorder-back ( string i -- )
    over [ non-starter? not ] find-last* 1+* reorder-next 2drop ;

: decompose ( string quot -- decomposed )
    ! When there are 8 and 32-bit strings, this'll be
    ! equivalent to clone on 8 and the contents of the last
    ! main quotation on 32.
    over [ 127 < ] all? [ drop ] [
        swap [ [
            dup hangul? [ hangul>jamo % drop ]
            [ dup rot call [ % ] [ , ] ?if ] if
        ] curry* each ] "" make*
        dup reorder
    ] if ; inline

: nfd ( string -- string )
    [ canonical-entry ] decompose ;

: nfkd ( string -- string )
    [ compat-entry ] decompose ;

: string-append ( s1 s2 -- string )
    ! This could be more optimized,
    ! but in practice, it'll almost always just be append
    [ append ] keep
    0 over ?nth non-starter?
    [ length dupd reorder-back ] [ drop ] if ;

! Normalization -- Composition
SYMBOL: main-str
SYMBOL: ind
SYMBOL: after
SYMBOL: char

: get-str ( i -- ch ) ind get + main-str get ?nth ;
: current ( -- ch ) 0 get-str ;
: to ( -- ) ind inc ;

: initial-medial? ( -- ? )
    current initial? [ 1 get-str medial? ] [ f ] if ;

: --final? ( -- ? )
    2 get-str final? ;

: imf, ( -- )
    current to current to current jamo>hangul , ;

: im, ( -- )
    current to current 0 jamo>hangul , ;

: compose-jamo ( -- )
    initial-medial? [
        --final? [ imf, ] [ im, ] if
    ] when to current jamo? [ compose-jamo ] when ;

: pass-combining ( -- )
    current non-starter? [ current , to pass-combining ] when ;

: try-compose ( last-class char current-class -- )
    swapd = [ after get push ] [
        char get over combine-chars
        [ nip char set ] [ after get push ] if*
    ] if ;

: compose-iter ( n -- )
    current [
        dup combining-class dup
        [ [ try-compose ] keep to compose-iter ] [ 3drop ] if
    ] [ drop ] if* ;

: ?new-after ( -- )
    after [ dup empty? [ drop SBUF" " clone ] unless ] change ;

: (compose) ( -- )
    current [
        dup jamo? [ drop compose-jamo ] [
            char set to ?new-after
            0 compose-iter
            char get , after get %
            to
        ] if (compose)
    ] when* ;

: compose ( str -- comp )
    [
        main-str set
        0 ind set
        SBUF" " clone after set
        pass-combining (compose)
    ] "" make* ;

: nfc ( string -- nfc )
    nfd compose ;

: nfkc ( string -- nfkc )
    nfkc compose ;
