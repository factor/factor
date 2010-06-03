! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel sets
sequences parser ;
QUALIFIED: sets
IN: hash-sets

! In a better implementation, less memory would be used
TUPLE: hash-set { table hashtable read-only } ;

: <hash-set> ( members -- hash-set )
    H{ } clone [ [ dupd set-at ] curry each ] keep hash-set boa ;

INSTANCE: hash-set set
M: hash-set in? table>> key? ; inline
M: hash-set adjoin table>> dupd set-at ; inline
M: hash-set delete table>> delete-at ; inline
M: hash-set members table>> keys ; inline
M: hash-set set-like drop dup hash-set? [ members <hash-set> ] unless ;
M: hash-set clone table>> clone hash-set boa ;
M: hash-set null? table>> assoc-empty? ;

M: sequence fast-set <hash-set> ;
M: f fast-set drop H{ } clone hash-set boa ;

M: sequence duplicates
    f fast-set [ [ in? ] [ adjoin ] 2bi ] curry filter ;

<PRIVATE

: (all-unique?) ( elt hash -- ? )
    2dup in? [ 2drop f ] [ adjoin t ] if ; inline

PRIVATE>

M: sequence all-unique?
    dup length <hashtable> hash-set boa
    [ (all-unique?) ] curry all? ;
