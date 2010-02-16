! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bit-arrays bit-sets hashtables kernel
math sequences parser prettyprint.custom ;
QUALIFIED: sets
IN: bags
! The vocab is called bags for now, but only until it gets into core
! All the code here is in the style that could be put in core

! Set protocol
MIXIN: set
GENERIC: adjoin ( elt set -- )
GENERIC: in? ( elt set -- ? )
GENERIC: delete ( elt set -- )
GENERIC: set-like ( set exemplar -- set' )
GENERIC: fast-set ( set -- set' )
GENERIC: items ( set -- sequence )
GENERIC: union ( set1 set2 -- set )
GENERIC: intersect ( set1 set2 -- set )
GENERIC: intersects? ( set1 set2 -- ? )
GENERIC: diff ( set1 set2 -- set )
GENERIC: subset? ( set1 set2 -- ? )
GENERIC: set= ( set1 set2 -- ? )

! Defaults for some methods.
! Override them for efficiency

M: set union
    [ [ items ] bi@ append ] keep set-like ;

<PRIVATE

: sequence/tester ( set1 set2 -- set1' quot )
    [ items ] [ fast-set [ in? ] curry ] bi* ; inline

PRIVATE>

M: set intersect
    [ sequence/tester filter ] keep set-like ;

M: set diff
    [ sequence/tester [ not ] compose filter ] keep set-like ;

M: set intersects?
    sequence/tester any? ;

M: set subset?
    sequence/tester all? ;
    
M: set set=
    2dup subset? [ swap subset? ] [ 2drop f ] if ;

M: set fast-set ;

! Hash sets
! In a better implementation, less memory would be used
TUPLE: hash-set { table hashtable read-only } ;

: <hash-set> ( items -- hash-set )
    sets:unique hash-set boa ;

INSTANCE: hash-set set
M: hash-set in? table>> key? ; inline
M: hash-set adjoin table>> dupd set-at ; inline
M: hash-set delete table>> delete-at ; inline
M: hash-set items table>> keys ; inline
M: hash-set set-like
    drop dup hash-set? [ items <hash-set> ] unless ;
M: hash-set clone
    table>> clone hash-set boa ;

SYNTAX: HS{
    \ } [ <hash-set> ] parse-literal ;

M: hash-set pprint* pprint-object ;
M: hash-set pprint-delims drop \ HS{ \ } ;
M: hash-set >pprint-sequence items ;

! Sequences are sets
INSTANCE: sequence set
M: sequence in? member? ; inline
M: sequence adjoin sets:adjoin ; inline
M: sequence delete remove! drop ; inline
M: sequence set-like
    [ dup sequence? [ sets:prune ] [ items ] if ] dip
    like ;
M: sequence items ;
M: sequence fast-set <hash-set> ;

! Bit sets are sets
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
: (bit-set-op) ( set1 set2 -- table1 table2 )
    [ set-like ] keep [ table>> ] bi@ ; inline

: bit-set-op ( set1 set2 quot: ( table1 table2 -- table ) -- bit-set )
    [ (bit-set-op) ] dip call bit-set boa ; inline

M: bit-set union
    [ bit-set-union ] bit-set-op ;

M: bit-set intersect
    [ bit-set-intersect ] bit-set-op ;

M: bit-set diff
    [ bit-set-diff ] bit-set-op ;

M: bit-set subset?
    (bit-set-op) swap bit-set-subset? ;

M: bit-set items
    [ table>> length iota ] keep [ in? ] curry filter ;

M: bit-set set-like
    ! This crashes if there are keys that can't be put in the bit set
    over bit-set? [ 2dup [ table>> ] bi@ length = ] [ f ] if
    [ drop ] [
        [ items ] dip table>> length <bit-set>
        [ [ adjoin ] curry each ] keep
    ] if ;
