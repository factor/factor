! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences namespaces make unicode.data kernel math arrays
locals sorting.insertion accessors assocs math.order combinators
unicode.syntax strings sbufs ;
IN: unicode.normalize

<PRIVATE
! Conjoining Jamo behavior

CONSTANT: hangul-base HEX: ac00
CONSTANT: hangul-end HEX: D7AF
CONSTANT: initial-base HEX: 1100
CONSTANT: medial-base HEX: 1161
CONSTANT: final-base HEX: 11a7

CONSTANT: initial-count 19
CONSTANT: medial-count 21
CONSTANT: final-count 28

: ?between? ( n/f from to -- ? )
    pick [ between? ] [ 3drop f ] if ;

: hangul? ( ch -- ? ) hangul-base hangul-end ?between? ;
: jamo? ( ch -- ? ) HEX: 1100 HEX: 11FF ?between? ;

! These numbers come from UAX 29
: initial? ( ch -- ? )
    dup HEX: 1100 HEX: 1159 ?between? [ ] [ HEX: 115F = ] ?if ;
: medial? ( ch -- ? ) HEX: 1160 HEX: 11A2 ?between? ;
: final? ( ch -- ? ) HEX: 11A8 HEX: 11F9 ?between? ;

: hangul>jamo ( hangul -- jamo-string )
    hangul-base - final-count /mod final-base +
    [
        medial-count /mod medial-base +
        [ initial-base + ] dip
    ] dip
    dup final-base = [ drop 2array ] [ 3array ] if ;

: jamo>hangul ( initial medial final -- hangul )
    [
        [ initial-base - medial-count * ] dip
        medial-base - + final-count *
    ] dip final-base - + hangul-base + ;

! Normalization -- Decomposition 

: reorder-slice ( string start -- slice done? )
    2dup swap [ non-starter? not ] find-from drop
    [ [ over length ] unless* rot <slice> ] keep not ;

: reorder-next ( string i -- new-i done? )
    over [ non-starter? ] find-from drop [
        reorder-slice
        [ dup [ combining-class ] insertion-sort to>> ] dip
    ] [ length t ] if* ;

: reorder-loop ( string start -- )
    dupd reorder-next [ 2drop ] [ reorder-loop ] if ;

: reorder ( string -- )
    0 reorder-loop ;

: reorder-back ( string i -- )
    over [ non-starter? not ] find-last-from drop ?1+ reorder-next 2drop ;

:: decompose ( string quot -- decomposed )
    [let | out [ string length <sbuf> ] |
        string [
            dup hangul? [ hangul>jamo out push-all ]
            [ dup quot call [ out push-all ] [ out push ] ?if ] if
        ] each out >string
    ] dup reorder ;

: with-string ( str quot -- str )
    over aux>> [ call ] [ drop ] if ; inline

: (nfd) ( string -- nfd )
    [ canonical-entry ] decompose ;

: (nfkd) ( string -- nfkd )
    [ compatibility-entry ] decompose ;

PRIVATE>

: nfd ( string -- nfd )
    [ (nfd) ] with-string ;

: nfkd ( string -- nfkd )
    [ (nfkd) ] with-string ;

: string-append ( s1 s2 -- string )
    [ append ] keep
    0 over ?nth non-starter?
    [ length dupd reorder-back ] [ drop ] if ;

<PRIVATE

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
    current to current final-base jamo>hangul , ;

: compose-jamo ( -- )
    initial-medial? [
        --final? [ imf, ] [ im, ] if
    ] [ current , ] if to ;

: pass-combining ( -- )
    current non-starter? [ current , to pass-combining ] when ;

:: try-compose ( last-class new-char current-class -- new-class )
    last-class current-class = [ new-char after get push last-class ] [
        char get new-char combine-chars
        [ char set last-class ]
        [ new-char after get push current-class ] if*
    ] if ;

DEFER: compose-iter

: try-noncombining ( char -- )
    char get swap combine-chars
    [ char set to f compose-iter ] when* ;

: compose-iter ( last-class -- )
    current [
        dup combining-class {
            { f [ 2drop ] }
            { 0 [ swap [ drop ] [ try-noncombining ] if ] }
            [ try-compose to compose-iter ]
        } case
    ] [ drop ] if* ;

: ?new-after ( -- )
    after [ dup empty? [ drop SBUF" " clone ] unless ] change ;

: compose-combining ( ch -- )
    char set to ?new-after
    f compose-iter
    char get , after get % ;

: (compose) ( -- )
    current [
        dup jamo? [ drop compose-jamo ] [
            1 get-str combining-class
            [ compose-combining ] [ , to ] if
        ] if (compose)
    ] when* ;

: combine ( str -- comp )
    [
        main-str set
        0 ind set
        SBUF" " clone after set
        pass-combining (compose)
    ] "" make ;

PRIVATE>

: nfc ( string -- nfc )
    [ (nfd) combine ] with-string ;

: nfkc ( string -- nfkc )
    [ (nfkd) combine ] with-string ;
