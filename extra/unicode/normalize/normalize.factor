USING: sequences namespaces unicode.load kernel combinators.lib math
unicode arrays ;
IN: unicode.normalize

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
