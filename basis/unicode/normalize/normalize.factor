! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii sequences namespaces make unicode.data kernel math arrays
locals sorting.insertion accessors assocs math.order combinators
strings sbufs hints combinators.short-circuit vectors ;
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
    pick [ between? ] [ 3drop f ] if ; inline

: hangul? ( ch -- ? ) hangul-base hangul-end ?between? ; inline
: jamo? ( ch -- ? ) HEX: 1100 HEX: 11FF ?between? ; inline

! These numbers come from UAX 29
: initial? ( ch -- ? )
    dup HEX: 1100 HEX: 1159 ?between? [ ] [ HEX: 115F = ] ?if ; inline
: medial? ( ch -- ? ) HEX: 1160 HEX: 11A2 ?between? ; inline
: final? ( ch -- ? ) HEX: 11A8 HEX: 11F9 ?between? ; inline

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
    [ [ over length ] unless* rot <slice> ] keep not ; inline

: reorder-next ( string i -- new-i done? )
    over [ non-starter? ] find-from drop [
        reorder-slice
        [ dup [ combining-class ] insertion-sort to>> ] dip
    ] [ length t ] if* ; inline

: reorder-loop ( string start -- )
    dupd reorder-next [ 2drop ] [ reorder-loop ] if ; inline recursive

: reorder ( string -- )
    0 reorder-loop ;

: reorder-back ( string i -- )
    over [ non-starter? not ] find-last-from drop ?1+ reorder-next 2drop ;

:: decompose ( string quot -- decomposed )
    string length <sbuf> :> out
    string [
        >fixnum dup ascii? [ out push ] [
            dup hangul? [ hangul>jamo out push-all ]
            [ dup quot call [ out push-all ] [ out push ] ?if ] if
        ] if
    ] each
    out "" like dup reorder ; inline

: with-string ( str quot -- str )
    over aux>> [ call ] [ drop ] if ; inline

: (nfd) ( string -- nfd )
    [ canonical-entry ] decompose ;

HINTS: (nfd) string ;

: (nfkd) ( string -- nfkd )
    [ compatibility-entry ] decompose ;

HINTS: (nfkd) string ;

PRIVATE>

: nfd ( string -- nfd )
    [ (nfd) ] with-string ;

: nfkd ( string -- nfkd )
    [ (nfkd) ] with-string ;

: string-append ( s1 s2 -- string )
    [ append ] keep
    0 over ?nth non-starter?
    [ length dupd reorder-back ] [ drop ] if ;

HINTS: string-append string string ;

<PRIVATE

! Normalization -- Composition

: initial-medial? ( str i -- ? )
    { [ swap nth initial? ] [ 1 + swap ?nth medial? ] } 2&& ;

: --final? ( str i -- ? )
    2 + swap ?nth final? ;

: imf, ( str i -- str i )
    [ tail-slice first3 jamo>hangul , ]
    [ 3 + ] 2bi ;

: im, ( str i -- str i )
    [ tail-slice first2 final-base jamo>hangul , ]
    [ 2 + ] 2bi ;

: compose-jamo ( str i -- str i )
    2dup initial-medial? [
        2dup --final? [ imf, ] [ im, ] if
    ] [ 2dup swap nth , 1 + ] if ;

: pass-combining ( str -- str i )
    dup [ non-starter? not ] find drop
    [ dup length ] unless*
    2dup head-slice % ;

TUPLE: compose-state i str char after last-class ;

: get-str ( state i -- ch )
    swap [ i>> + ] [ str>> ] bi ?nth ; inline
: current ( state -- ch ) 0 get-str ; inline
: to ( state -- state ) [ 1 + ] change-i ; inline
: push-after ( ch state -- state ) [ ?push ] change-after ; inline

:: try-compose ( state new-char current-class -- state )
    state last-class>> current-class =
    [ new-char state push-after ] [
        state char>> new-char combine-chars
        [ state swap >>char ] [
            new-char state push-after
            current-class >>last-class
        ] if*
    ] if ; inline

DEFER: compose-iter

: try-noncombining ( state char -- state )
    [ drop ] [ [ char>> ] dip combine-chars ] 2bi
    [ >>char to f >>last-class compose-iter ] when* ; inline

: compose-iter ( state -- state )
    dup current [
        dup combining-class {
            { f [ drop ] }
            { 0 [
                over last-class>>
                [ drop ] [ try-noncombining ] if ] }
            [ try-compose to compose-iter ]
        } case
    ] when* ; inline recursive

: compose-combining ( ch str i -- str i )
    compose-state new
        swap >>i
        swap >>str
        swap >>char
    compose-iter
    { [ char>> , ] [ after>> % ] [ str>> ] [ i>> ] } cleave ; inline

:: (compose) ( str i -- )
    i str ?nth [
        dup jamo? [ drop str i compose-jamo ] [
            i 1 + str ?nth combining-class
            [ str i 1 + compose-combining ] [ , str i 1 + ] if
        ] if (compose)
    ] when* ; inline recursive

: combine ( str -- comp )
    [ pass-combining (compose) ] "" make ;

HINTS: combine string ;

PRIVATE>

: nfc ( string -- nfc )
    [ (nfd) combine ] with-string ;

: nfkc ( string -- nfkc )
    [ (nfkd) combine ] with-string ;
