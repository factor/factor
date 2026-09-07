USING: accessors alien.c-types alien.data arrays checksums
combinators cuckoo-filters kernel locals math.parser random
random.mersenne-twister sequences tools.test ;
IN: cuckoo-filters.tests

SINGLETON: test-checksum
M: test-checksum checksum-bytes drop ;

: test-key ( fingerprint -- bytes ) 0 2array uint >c-array underlying>> ;

: <test-filter> ( -- filter )
    4 f <array> 1array test-checksum 0 cuckoo-filter boa ;

! Different keys can have the same fingerprint and candidate buckets.
! A positive lookup must not prevent inserting another key (#2236).
{ t t t 2 t t 0 } [
    [let
        <test-filter> :> filter
        1 test-key filter cuckoo-insert
        1 1 2array uint >c-array underlying>> filter cuckoo-lookup
        1 1 2array uint >c-array underlying>> filter cuckoo-insert
        filter size>>
        1 test-key filter cuckoo-delete
        1 1 2array uint >c-array underlying>> filter cuckoo-delete
        filter size>>
    ]
] unit-test

TUPLE: alternating-random turn ;
M: alternating-random random-32*
    [ not ] change-turn turn>> 0x40000000 0 ? ;

! Exhausting the relocation limit must not evict an existing entry.
{ f 4 t } [
    [let
        <test-filter> :> filter
        { 1 2 3 4 } [ test-key filter cuckoo-insert drop ] each
        alternating-random new [
            5 test-key filter cuckoo-insert
        ] with-random
        filter size>>
        { 1 2 3 4 } [ test-key filter cuckoo-lookup ] all?
    ]
] unit-test

{ t 1 t t f 0 } [
    "factor" 100 <cuckoo-filter> {
        [ cuckoo-insert ]
        [ nip size>> ]
        [ cuckoo-lookup ]
        [ cuckoo-delete ]
        [ cuckoo-lookup ]
        [ nip size>> ]
    } 2cleave
] unit-test

{ 250,000 250,000 0 } [
    1234 <mersenne-twister> [
        250,000 <cuckoo-filter>
        250,000 [ number>string ] map-integers
        [
            [ over cuckoo-insert ] count swap
        ]
        [ [ over cuckoo-lookup ] count swap ]
        [ [ over cuckoo-delete drop ] each ] tri
        size>>
    ] with-random
] unit-test
