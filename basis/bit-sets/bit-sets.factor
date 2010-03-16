! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences byte-arrays bit-arrays math hints sets ;
IN: bit-sets

TUPLE: bit-set { table bit-array read-only } ;

: <bit-set> ( capacity -- bit-set )
    <bit-array> bit-set boa ;

INSTANCE: bit-set set

M: bit-set in?
    over integer? [ table>> ?nth ] [ 2drop f ] if ; inline

M: bit-set adjoin
    ! This is allowed to crash when the elt couldn't go in the set
    [ t ] 2dip table>> set-nth ;

M: bit-set delete
    ! This isn't allowed to crash if the elt wasn't in the set
    over integer? [
        table>> 2dup bounds-check? [
            [ f ] 2dip set-nth
        ] [ 2drop ] if
    ] [ 2drop ] if ;

! If you do binary set operations with a bitset, it's expected
! that the other thing can also be represented as a bitset
! of the same length.
<PRIVATE

: bit-set-map ( seq1 seq2 quot -- seq )
    [ 2drop length>> ]
    [
        [
            [ [ length ] bi@ assert= ]
            [ [ underlying>> ] bi@ ] 2bi
        ] dip 2map
    ] 3bi bit-array boa ; inline

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
    [ table>> length iota ] keep [ in? ] curry filter ;

M: bit-set set-like
    ! This crashes if there are keys that can't be put in the bit set
    over bit-set? [ 2dup [ table>> ] bi@ length = ] [ f ] if
    [ drop ] [
        [ members ] dip table>> length <bit-set>
        [ [ adjoin ] curry each ] keep
    ] if ;

M: bit-set clone
    table>> clone bit-set boa ;
