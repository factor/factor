USING: accessors arrays assocs combinators.short-circuit fry
hints interval-maps kernel math math.order sequences sorting
strings unicode.breaks.private unicode.case.private
unicode.categories unicode.collation unicode.collation.private
unicode.data unicode.data.private unicode.normalize.private
unicode.script ranges ;
IN: unicode

CATEGORY: blank Zs Zl Zp | "\r\n\t" member? ;

CATEGORY: letter Ll | "Other_Lowercase" property? ;

CATEGORY: LETTER Lu | "Other_Uppercase" property? ;

CATEGORY: Letter Lu Ll Lt Lm Lo Nl ;

CATEGORY: digit Nd Nl No ;

CATEGORY-NOT: printable Cc Cf Cs Co Cn ;

CATEGORY: alpha Lu Ll Lt Lm Lo Nd Nl No | "Other_Alphabetic" property? ;

CATEGORY: control Cc ;

CATEGORY-NOT: uncased Lu Ll Lt Lm Mn Me ;

CATEGORY-NOT: character Cn ;

CATEGORY: math Sm | "Other_Math" property? ;

: script-of ( char -- script )
    script-table interval-at ;

: name>char ( name -- char ) name-map at ; inline

: char>name ( char -- name ) name-map value-at ; inline

: ch>lower ( ch -- lower ) simple-lower ?at drop ; inline

: ch>upper ( ch -- upper ) simple-upper ?at drop ; inline

: ch>title ( ch -- title ) simple-title ?at drop ; inline

:: first-grapheme ( entire-str start -- i )
    start :> pos!
    entire-str length :> str-len
    0 pos 1 + entire-str <slice> grapheme-class
    pos 1 + str-len 1 - min pos!
    pos str-len 1 - [a..b] [
        1 + 0 swap entire-str <slice> grapheme-class
        dup rot swap grapheme-break?
    ] find drop nip
    [ 1 + ] [ str-len start - ] if* ;

:: first-grapheme-from ( start str -- i )
    str start first-grapheme start + ;

:: last-grapheme ( str -- i )
    str length 1 - :> pos!
    pos 0 = [ 0 ] [
        str grapheme-class
        pos 1 - 0 max pos!
        0 pos [a..b] [
            0 swap 1 + str <slice> grapheme-class
            dup rot grapheme-break?
        ] find-last drop ?1+ nip
    ] if ;

: last-grapheme-from ( end str -- i )
    swap head-slice last-grapheme ;

<PRIVATE

: >pieces ( str quot: ( str -- i ) -- graphemes )
    [ dup empty? not ] swap '[ dup @ cut-slice swap ] produce nip ; inline

PRIVATE>

:: >graphemes ( str -- graphemes )
    str length :> str-len
    0 :> pos! 0 :> old-pos!
    [ f ! dummy
      pos old-pos! old-pos str-len < [
          str pos first-grapheme pos + pos! pos str-len <=
      ] [ f ] if ]
    [ drop old-pos pos str <slice> ] produce nip ;

: count-graphemes ( str -- n ) >graphemes length ; inline

: string-reverse ( str -- rts )
    >graphemes reverse! concat ;

: first-word ( str -- i )
    [ [ length ] [ first word-break-prop ] bi ] keep
    1 swap dup '[ _ word-break-next ] find-index-from
    drop nip or* ;

: >words ( str -- words )
    [ first-word ] >pieces ;

<PRIVATE

: nth-next ( i str -- str[i-1] str[i] )
    [ [ 1 - ] keep ] dip '[ _ nth ] bi@ ;

PRIVATE>

: word-break-at? ( i str -- ? )
    {
        [ drop zero? ]
        [ length = ]
        [
            [ nth-next [ word-break-prop ] dip ] 2keep
            word-break-next nip
        ]
    } 2|| ;

: first-word-from ( start str -- i )
    over tail-slice first-word + ;

: last-word ( str -- i )
    [ length <iota> ] keep '[ _ word-break-at? ] find-last drop 0 or ;

: last-word-from ( end str -- i )
    swap head-slice last-word ;

: >lower ( string -- lower )
    locale>lower final-sigma
    [ lower>> ] [ ch>lower ] map-case ;

HINTS: >lower string ;

: >upper ( string -- upper )
    locale>upper
    [ upper>> ] [ ch>upper ] map-case ;

HINTS: >upper string ;

<PRIVATE

: (>title) ( string -- title )
    locale>upper
    [ title>> ] [ ch>title ] map-case ; inline

PRIVATE>

: capitalize ( string -- title )
    unclip-slice 1string [ >lower ] [ (>title) ] bi*
    "" prepend-as ; inline

: >title ( string -- title )
    final-sigma >words [ capitalize ] map! concat ;

HINTS: >title string ;

: >case-fold ( string -- fold )
    >upper >lower ;

: lower? ( string -- ? ) dup >lower sequence= ;

: upper? ( string -- ? ) dup >upper sequence= ;

: title? ( string -- ? ) dup >title sequence= ;

: case-fold? ( string -- ? ) dup >case-fold sequence= ;

: nfd ( string -- nfd )
    [ (nfd) ] with-string ;

: nfkd ( string -- nfkd )
    [ (nfkd) ] with-string ;

: string-append ( s1 s2 -- string )
    [ append ] keep
    0 over ?nth non-starter?
    [ length dupd reorder-back ] [ drop ] if ;

HINTS: string-append string string ;

: nfc ( string -- nfc )
    [ (nfd) combine ] with-string ;

: nfkc ( string -- nfkc )
    [ (nfkd) combine ] with-string ;

: collation-key/nfd ( string -- key nfd )
    nfd [
        string>graphemes graphemes>weights
        filter-ignorable weights>bytes
    ] keep ;

<PRIVATE

: insensitive= ( str1 str2 levels-removed -- ? )
    [
        [ collation-key/nfd drop ] dip
        [ [ 0 = not ] trim-tail but-last ] times
    ] curry same? ;

PRIVATE>

: primary= ( str1 str2 -- ? )
    3 insensitive= ;

: secondary= ( str1 str2 -- ? )
    2 insensitive= ;

: tertiary= ( str1 str2 -- ? )
    1 insensitive= ;

: quaternary= ( str1 str2 -- ? )
    0 insensitive= ;

: sort-strings ( strings -- sorted )
    [ collation-key/nfd 2array ] map sort values ;

: string<=> ( str1 str2 -- <=> )
    [ collation-key/nfd 2array ] compare ;

: upper-surrogate? ( ch -- ? ) 0xD800 0xDBFF between? ; inline

: under-surrogate? ( ch -- ? ) 0xDC00 0xDFFF between? ; inline

CONSTANT: unicode-supported {
    "collation"
}

CONSTANT: unicode-unsupported {
    "bidi"
}

CONSTANT: unicode-version "15.1.0"
