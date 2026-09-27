! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii combinators combinators.short-circuit
io.encodings.utf8 io.files kernel literals locals make math
math.order sbufs sequences sets splitting strings ;

IN: sqids

ERROR: alphabet-multibyte-char ;
ERROR: alphabet-too-short ;
ERROR: alphabet-duplicate-chars ;
ERROR: invalid-min-length min-length ;
ERROR: number-out-of-range n ;
ERROR: max-attempts-reached ;

CONSTANT: default-alphabet
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

CONSTANT: default-min-length 0

CONSTANT: default-blocklist $[
    "vocab:sqids/blocklist.txt" utf8 file-lines harvest
]

TUPLE: sqids alphabet min-length blocklist ;

<PRIVATE

! Deterministic shuffle: produces the same result every time
:: sqids-shuffle ( alphabet -- alphabet' )
    alphabet clone :> chars
    chars length :> len
    len 1 - <iota> [| i |
        len 1 - i - :> j
        i j * i chars nth + j chars nth + len mod :> r
        i r chars exchange
    ] each
    chars ;

! Encode integer to a string in the base given by alphabet's length
:: to-id ( n alphabet -- str )
    alphabet length :> base
    SBUF" " clone n [
        base /mod alphabet nth pick push
        dup 0 >
    ] loop drop
    reverse! >string ;

! Decode a string to an integer using alphabet as digit set
:: to-number ( str alphabet -- n )
    alphabet length :> base
    str 0 [ alphabet index swap base * + ] reduce ;

:: filter-blocklist ( blocklist alphabet -- filtered )
    alphabet >lower :> lower-alpha
    blocklist [ length 3 >= ] filter [ >lower ] map
    [ [ lower-alpha member? ] all? ] filter members ;

: validate-alphabet ( alphabet -- alphabet )
    dup [ 127 > ] any? [ alphabet-multibyte-char ] when
    dup length 3 < [ alphabet-too-short ] when
    dup all-unique? [ alphabet-duplicate-chars ] unless ;

: validate-min-length ( min-length -- min-length )
    dup { [ integer? ] [ 0 255 between? ] } 1&&
    [ invalid-min-length ] unless ;

:: blocked-id? ( id sqids -- ? )
    id >lower :> lower-id
    sqids blocklist>> [| word |
        {
            { [ word length 3 = ] [ lower-id word = ] }
            { [ word [ digit? ] any? ] [
                lower-id word head? lower-id word tail? or
            ] }
            [ lower-id word subseq-of? ]
        } cond
    ] any? ;

! Compute the starting offset from input numbers
:: starting-offset ( numbers alphabet -- offset )
    alphabet length :> len
    numbers numbers length [| sum v i |
        v len mod alphabet nth sum + i +
    ] reduce-index len mod ;

! Encode each number into sbuf, threading alphabet through shuffle
:: write-numbers ( sbuf alphabet numbers -- alphabet' )
    numbers length :> n
    numbers alphabet [| alpha v i |
        v alpha rest to-id sbuf push-all
        i n 1 - < [
            alpha first sbuf push
            alpha sqids-shuffle
        ] [ alpha ] if
    ] reduce-index ;

! Pad sbuf with separator + alphabet chunks until it reaches min-length
:: pad-to-min-length ( sbuf alphabet min-length -- )
    sbuf length min-length < [
        alphabet first sbuf push
        alphabet [ sbuf length min-length < ] [
            sqids-shuffle dup
            min-length sbuf length - over length min head
            sbuf push-all
        ] while drop
    ] when ;

:: encode-numbers ( sqids numbers increment -- str )
    sqids alphabet>> :> alphabet
    alphabet length :> len
    increment len > [ max-attempts-reached ] when

    numbers alphabet starting-offset increment + len mod :> offset
    alphabet offset cut swap append :> rotated
    rotated first 1string >sbuf :> sbuf
    sbuf rotated reverse numbers write-numbers :> shuffled
    sbuf shuffled sqids min-length>> pad-to-min-length

    sbuf >string dup sqids blocked-id?
    [ drop sqids numbers increment 1 + encode-numbers ] when ;

! An empty chunk marks the start of padding.
:: decode-numbers ( id alphabet -- )
    id alphabet first 1string split1 :> ( before after )
    before empty? [
        before alphabet rest to-number ,
        after [ after alphabet sqids-shuffle decode-numbers ] when
    ] unless ;

PRIVATE>

:: <sqids> ( alphabet min-length blocklist -- sqids )
    alphabet validate-alphabet drop
    min-length validate-min-length drop
    alphabet sqids-shuffle
    min-length
    blocklist alphabet filter-blocklist
    sqids boa ;

: <default-sqids> ( -- sqids )
    default-alphabet default-min-length default-blocklist <sqids> ;

:: sqids-encode ( sqids numbers -- str )
    numbers empty? [ "" ] [
        numbers [
            dup { [ integer? ] [ 0 >= ] } 1&&
            [ drop ] [ number-out-of-range ] if
        ] each
        sqids numbers 0 encode-numbers
    ] if ;

:: sqids-decode ( sqids id -- numbers )
    sqids alphabet>> :> alphabet
    id { [ empty? not ] [ [ alphabet member? ] all? ] } 1&& [
        id first alphabet index :> offset
        alphabet offset cut swap append reverse :> rotated
        [ id rest rotated decode-numbers ] { } make
    ] [ { } ] if ;
