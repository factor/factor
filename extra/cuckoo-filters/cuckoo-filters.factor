! Copyright (C) 2016 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors alien alien.c-types alien.data arrays checksums
checksums.sha combinators.short-circuit kernel locals math
math.bitwise random sequences ;

IN: cuckoo-filters

<PRIVATE

! The maximum number of times we kick down items/displace from
! their buckets
CONSTANT: max-cuckoo-count 500

! The maximum load factor we allow before growing the capacity
CONSTANT: max-load-factor 0.96

! The number of tags to store in each bucket
CONSTANT: bucket-size 4

: #buckets ( capacity -- #buckets )
    [ bucket-size /i next-power-of-2 ] keep
    over / bucket-size / max-load-factor > [ 2 * ] when ;

: <cuckoo-buckets> ( capacity -- buckets )
    #buckets [ bucket-size f <array> ] replicate ;

: tag-index ( hash -- tag index )
    4 over <displaced-alien> [ uint deref ] bi@ ;

: alt-index ( tag index -- altindex )
    [ 0x5bd1e995 w* ] [ bitxor ] bi* ;

: tag-indices ( bytes cuckoo-filter -- tag i1 i2 )
    checksum>> checksum-bytes tag-index 2dup alt-index ;

: bucket-lookup ( fingerprint bucket -- ? )
    member? ;

: bucket-insert ( fingerprint bucket -- ? )
    dup [ not ] find drop [ swap set-nth t ] [ 2drop f ] if* ;

: bucket-delete ( fingerprint bucket -- ? )
    [ f ] 2dip [ index ] keep over [ set-nth t ] [ 3drop f ] if ;

: bucket-swap ( fingerprint bucket -- fingerprint' )
    [ length random ] keep [ swap ] change-nth ;

PRIVATE>

TUPLE: cuckoo-filter buckets checksum size ;

: <cuckoo-filter> ( capacity -- cuckoo-filter )
    <cuckoo-buckets> sha1 0 cuckoo-filter boa ;

:: cuckoo-insert ( bytes cuckoo-filter -- ? )
    bytes cuckoo-filter tag-indices :> ( tag! i1 i2 )
    cuckoo-filter buckets>> :> buckets
    buckets length :> n
    {
        [ tag i1 n mod buckets nth bucket-insert ]
        [ tag i2 n mod buckets nth bucket-insert ]
    } 0|| [
        cuckoo-filter [ 1 + ] change-size drop t
    ] [
        cuckoo-filter checksum>> :> checksum
        2 random zero? i1 i2 ? :> i!
        max-cuckoo-count [
            drop
            tag i n mod buckets nth bucket-swap tag!
            tag i alt-index i!

            tag i n mod buckets nth bucket-insert
            dup [ cuckoo-filter [ 1 + ] change-size drop ] when
        ] find-integer >boolean
    ] if ;

:: cuckoo-lookup ( bytes cuckoo-filter -- ? )
    bytes cuckoo-filter tag-indices :> ( tag i1 i2 )
    cuckoo-filter buckets>> :> buckets
    buckets length :> n
    {
        [ tag i1 n mod buckets nth bucket-lookup ]
        [ tag i2 n mod buckets nth bucket-lookup ]
    } 0|| ;

:: cuckoo-delete ( bytes cuckoo-filter -- ? )
    bytes cuckoo-filter tag-indices :> ( tag i1 i2 )
    cuckoo-filter buckets>> :> buckets
    buckets length :> n
    {
        [ tag i1 n mod buckets nth bucket-delete ]
        [ tag i2 n mod buckets nth bucket-delete ]
    } 0||
    dup [ cuckoo-filter [ 1 - ] change-size drop ] when ;
