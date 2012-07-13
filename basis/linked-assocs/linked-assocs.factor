! Copyright (C) 2008 Slava Pestov, James Cash.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs arrays kernel deques dlists sequences fry ;
IN: linked-assocs

TUPLE: linked-assoc assoc dlist ;

: <linked-assoc> ( exemplar -- assoc )
    0 swap new-assoc <dlist> linked-assoc boa ;

: <linked-hash> ( -- assoc )
    H{ } <linked-assoc> ;

M: linked-assoc assoc-size assoc>> assoc-size ;

M: linked-assoc at* assoc>> at* [ [ obj>> second ] when ] keep ;

M: linked-assoc delete-at
    [ [ assoc>> ] [ dlist>> ] bi [ at ] dip '[ _ delete-node ] when* ]
    [ assoc>> delete-at ] 2bi ;

<PRIVATE
: add-to-dlist ( value key lassoc -- node )
    [ swap 2array ] dip dlist>> push-back* ;
PRIVATE>

M: linked-assoc set-at
    [ 2dup assoc>> key? [ 2dup delete-at ] when add-to-dlist ] 2keep
    assoc>> set-at ;

M: linked-assoc >alist
    dlist>> dlist>sequence ;

M: linked-assoc clear-assoc
    [ assoc>> clear-assoc ] [ dlist>> clear-deque ] bi ;

M: linked-assoc clone 
    [ assoc>> clone ] [ dlist>> clone ] bi
    linked-assoc boa ;

INSTANCE: linked-assoc assoc
