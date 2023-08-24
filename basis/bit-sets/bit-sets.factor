! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors bit-arrays kernel math math.bitwise sequences
sequences.private sets ;
IN: bit-sets

TUPLE: bit-set { table bit-array read-only } ;

: <bit-set> ( capacity -- bit-set )
    <bit-array> bit-set boa ; inline

INSTANCE: bit-set set

M: bit-set in?
    over integer? [ table>> ?nth ] [ 2drop f ] if ; inline

M: bit-set adjoin
    ! This is allowed to throw an error when the elt couldn't
    ! go in the set
    [ t ] 2dip table>> set-nth ;

M: bit-set delete
    ! This isn't allowed to throw an error if the elt wasn't
    ! in the set
    over integer? [ [ f ] 2dip table>> ?set-nth ] [ 2drop ] if ;

! If you do binary set operations with a bit-set, it's expected
! that the other thing can also be represented as a bit-set
! of the same length.
<PRIVATE

ERROR: check-bit-set-failed ;

: check-bit-set ( bit-set -- bit-set )
    dup bit-set? [ check-bit-set-failed ] unless ; inline

: bit-set-map ( seq1 seq2 quot -- seq )
    [ drop 2length [ assert= ] keep ]
    [ [ [ underlying>> ] bi@ ] dip 2map ] 3bi
    bit-array boa ; inline

: (bit-set-op) ( set1 set2 -- table1 table2 )
    [ set-like ] keep [ table>> ] bi@ ; inline

: bit-set-op ( set1 set2 quot: ( a b -- c ) -- bit-set )
    [ (bit-set-op) ] dip bit-set-map bit-set boa ; inline

PRIVATE>

M: bit-set union
    [ bitor ] bit-set-op ;

M: bit-set intersect
    [ bitand ] bit-set-op ;

M: bit-set diff
    [ bitnot bitand ] bit-set-op ;

M: bit-set subset?
    [ intersect ] keep = ;

M: bit-set members
    table>> [ length <iota> ] keep '[ _ nth-unsafe ] filter ;

<PRIVATE

: bit-set-like ( set bit-set -- bit-set' )
    ! Throws an error if there are keys that can't be put
    ! in the bit set
    over bit-set? [ 2dup [ table>> length ] same? ] [ f ] if
    [ drop ] [
        [ members ] dip table>> length <bit-set>
        [ adjoin-all ] keep
    ] if ;

PRIVATE>

M: bit-set set-like
    bit-set-like check-bit-set ; inline

M: bit-set clone
    table>> clone bit-set boa ;

M: bit-set cardinality
    table>> bit-count ;
