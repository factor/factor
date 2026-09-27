! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays byte-vectors combinators
kernel locals math math.order sequences vectors ;
QUALIFIED-WITH: bitstreams bs
IN: compression.deflate

ERROR: invalid-deflate reason ;

<PRIVATE

CONSTANT: length-bases {
    3 4 5 6 7 8 9 10 11 13 15 17 19 23 27 31
    35 43 51 59 67 83 99 115 131 163 195 227 258
}
CONSTANT: length-extras {
    0 0 0 0 0 0 0 0 1 1 1 1 2 2 2 2
    3 3 3 3 4 4 4 4 5 5 5 5 0
}
CONSTANT: distance-bases {
    1 2 3 4 5 7 9 13 17 25 33 49 65 97 129 193
    257 385 513 769 1025 1537 2049 3073 4097 6145
    8193 12289 16385 24577
}
CONSTANT: distance-extras {
    0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6
    7 7 8 8 9 9 10 10 11 11 12 12 13 13
}
CONSTANT: code-length-order {
    16 17 18 0 8 7 9 6 10 5 11 4 12 3 13 2 14 1 15
}

:: read-bits ( n reader -- value )
    n reader bs:enough-bits? [
        n reader bs:read
    ] [ "truncated input" invalid-deflate ] if ;

! Canonical codes are indexed by (1 << length) + code. Zero-length
! entries have no code. Only a single one-bit code may be incomplete.
:: huffman-table ( lengths single? -- table )
    16 0 <array> :> counts
    lengths [| n | n counts nth 1 + n counts set-nth ] each
    1 :> left!
    15 [| i |
        left 2 * i 1 + counts nth - left!
        left 0 < [ "oversubscribed Huffman tree" invalid-deflate ] when
    ] each-integer
    left 0 > [
        single? 1 counts nth 1 = and
        lengths [ 0 > ] count 1 = and
        [ "incomplete Huffman tree" invalid-deflate ] unless
    ] when
    16 0 <array> :> next
    0 :> code!
    15 [| i |
        code i zero? [ 0 ] [ i counts nth ] if + 2 * code!
        code i 1 + next set-nth
    ] each-integer
    H{ } clone :> table
    lengths [| n symbol |
        n 0 > [
            n next nth :> c
            symbol 1 n shift c + table set-at
            c 1 + n next set-nth
        ] when
    ] each-index
    table ;

:: read-code ( table reader -- symbol )
    1 :> code!
    f :> symbol!
    0 :> n!
    [ symbol not n 15 < and ] [
        code 2 * 1 reader read-bits + code!
        code table at symbol!
        n 1 + n!
    ] while
    symbol [ symbol ] [ "invalid Huffman code" invalid-deflate ] if ;

: fixed-lengths ( -- lengths )
    288 [
        { { [ dup 144 < ] [ drop 8 ] }
          { [ dup 256 < ] [ drop 9 ] }
          { [ dup 280 < ] [ drop 7 ] }
          [ drop 8 ] } cond
    ] map-integers ;

:: read-lengths ( count table reader -- lengths )
    V{ } clone :> lengths
    [ lengths length count < ] [
        table reader read-code :> code
        code 16 < [ code lengths push ] [
            code {
                { 16 [
                    lengths empty? [ "repeat without previous length" invalid-deflate ] when
                    lengths last 2 reader read-bits 3 +
                ] }
                { 17 [ 0 3 reader read-bits 3 + ] }
                { 18 [ 0 7 reader read-bits 11 + ] }
            } case :> ( value n )
            lengths length n + count > [ "too many code lengths" invalid-deflate ] when
            n [ value lengths push ] times
        ] if
    ] while
    lengths ;

:: dynamic-tables ( reader -- literals distances )
    5 reader read-bits 257 + :> nl
    5 reader read-bits 1 + :> nd
    nl 286 > [ "reserved literal count" invalid-deflate ] when
    4 reader read-bits 4 + :> nc
    19 0 <array> :> lengths
    nc [| i |
        3 reader read-bits i code-length-order nth lengths set-nth
    ] each-integer
    lengths f huffman-table :> table
    nl nd + table reader read-lengths nl cut :> ( ll dl )
    256 ll nth zero? [ "missing end-of-block code" invalid-deflate ] when
    ll t huffman-table
    ! An empty distance alphabet is legal for a block containing only literals.
    dl [ zero? ] all? [ H{ } clone ] [ dl t huffman-table ] if ;

:: copy-match ( n distance output -- )
    distance output length > [ "distance exceeds output history" invalid-deflate ] when
    n [ output length distance - output nth output push ] times ;

:: compressed-block ( literals distances reader output -- )
    f :> done!
    [ done not ] [
        literals reader read-code :> symbol
        symbol 256 < [ symbol output push ] [
            symbol 256 = [ t done! ] [
                symbol 285 > [ "reserved length code" invalid-deflate ] when
                symbol 257 - :> i
                i length-bases nth i length-extras nth reader read-bits + :> n
                distances reader read-code :> d
                d 30 >= [ "reserved distance code" invalid-deflate ] when
                d distance-bases nth d distance-extras nth reader read-bits + :> distance
                n distance output copy-match
            ] if
        ] if
    ] while ;

:: stored-block ( reader output -- )
    8 reader bs:align
    16 reader read-bits :> n
    16 reader read-bits n 0xffff bitxor =
    [ "invalid stored block length" invalid-deflate ] unless
    n [ 8 reader read-bits output push ] times ;

TUPLE: deflate-writer bytes { buffer initial: 0 } { used initial: 0 } ;

: <deflate-writer> ( -- writer )
    deflate-writer new BV{ } clone >>bytes ;

:: write-bits ( value n writer -- )
    writer buffer>> value writer used>> shift bitor writer buffer<<
    writer used>> n + writer used<<
    [ writer used>> 8 >= ] [
        writer buffer>> 0xff bitand writer bytes>> push
        writer [ -8 shift ] change-buffer [ 8 - ] change-used drop
    ] while ;

:: finish-bits ( writer -- bytes )
    writer used>> 0 > [ writer buffer>> writer bytes>> push ] when
    writer bytes>> >byte-array ;

! Huffman codes are transmitted most-significant bit first, unlike
! the other fields of a DEFLATE stream.
:: write-code ( code n writer -- )
    n [| i | code n 1 - i - neg shift 1 bitand 1 writer write-bits ] each-integer ;

:: write-literal ( symbol writer -- )
    symbol {
        { [ dup 144 < ] [ 48 + 8 ] }
        { [ dup 256 < ] [ 256 + 9 ] }
        { [ dup 280 < ] [ 256 - 7 ] }
        [ 88 - 8 ]
    } cond writer write-code ;

:: base-index ( value bases -- i )
    bases [ value <= ] find-last drop ;

:: write-match ( n distance writer -- )
    n length-bases base-index :> l
    l 257 + writer write-literal
    n l length-bases nth - l length-extras nth writer write-bits
    distance distance-bases base-index :> d
    d 5 writer write-code
    distance d distance-bases nth - d distance-extras nth writer write-bits ;

! A bounded hash table keeps the most recent candidate for each three-byte
! prefix. Comparing the actual bytes makes hash collisions harmless.
:: prefix-hash ( i bytes -- hash )
    i bytes nth 8 shift i 1 + bytes nth 4 shift bitxor
    i 2 + bytes nth bitxor 0xffff bitand ;

:: match-length ( i previous bytes -- n )
    0 :> n!
    bytes length i - 258 min :> limit
    [
        n limit < [ i n + bytes nth previous n + bytes nth = ] [ f ] if
    ] [ n 1 + n! ] while n ;

:: fixed-deflate ( bytes -- compressed )
    <deflate-writer> :> writer
    3 3 writer write-bits
    65536 f <array> :> positions
    0 :> i!
    [ i bytes length < ] [
        0 :> n!
        0 :> distance!
        i 2 + bytes length < [
            i bytes prefix-hash :> hash
            hash positions nth :> previous
            previous [
                i previous - distance!
                distance 32768 <= [ i previous bytes match-length n! ] when
            ] when
        ] when
        n 3 >= [ n distance writer write-match ] [
            i bytes nth writer write-literal
            1 n!
        ] if
        n [| j |
            i j + :> pos
            pos 2 + bytes length < [ pos pos bytes prefix-hash positions set-nth ] when
        ] each-integer
        i n + i!
    ] while
    256 writer write-literal
    writer finish-bits ;

:: stored-deflate ( bytes -- compressed )
    <deflate-writer> :> writer
    0 :> i!
    f :> done!
    [ done not ] [
        bytes length i - 65535 min :> n
        i n + bytes length = done!
        done [ 1 ] [ 0 ] if 8 writer write-bits
        n 16 writer write-bits
        n 0xffff bitxor 16 writer write-bits
        i i n + bytes <slice> writer bytes>> push-all
        i n + i!
    ] while
    writer finish-bits ;

PRIVATE>

:: inflate ( bytes -- bytes' )
    bytes bs:<lsb0-bit-reader> :> reader
    BV{ } clone :> output
    f :> final!
    [ final not ] [
        1 reader read-bits 1 = final!
        2 reader read-bits {
            { 0 [ reader output stored-block ] }
            { 1 [
                fixed-lengths f huffman-table
                32 5 <array> f huffman-table
                reader output compressed-block
            ] }
            { 2 [ reader dynamic-tables reader output compressed-block ] }
            { 3 [ "reserved block type" invalid-deflate ] }
        } case
    ] while
    output >byte-array ;

:: deflate ( bytes -- bytes' )
    bytes fixed-deflate :> compressed
    bytes length dup 65534 + 65535 /i 1 max 5 * + compressed length <
    [ bytes stored-deflate ] [ compressed ] if ;
