! Copyright (C) 2008 Slava Pestov, James Cash.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs deques dlists fry kernel
sequences sequences.private ;
IN: linked-assocs

TUPLE: linked-assoc { assoc read-only } { dlist dlist read-only } ;

: <linked-assoc> ( exemplar -- assoc )
    0 swap new-assoc <dlist> linked-assoc boa ;

: <linked-hash> ( -- assoc )
    H{ } <linked-assoc> ;

M: linked-assoc assoc-size assoc>> assoc-size ;

M: linked-assoc at*
    assoc>> at* [ [ obj>> second-unsafe ] when ] keep ;

<PRIVATE

: (delete-at) ( key assoc dlist -- )
    '[ at [ _ delete-node ] when* ] [ delete-at ] 2bi ; inline

PRIVATE>

M: linked-assoc delete-at
    [ assoc>> ] [ dlist>> ] bi (delete-at) ;

<PRIVATE

: add-to-dlist ( value key dlist -- node )
    [ swap 2array ] dip push-back* ; inline

PRIVATE>

M: linked-assoc set-at
    [ assoc>> ] [ dlist>> ] bi
    '[ _ 2over key? [ 3dup (delete-at) ] when nip add-to-dlist ]
    [ set-at ] 2bi ;

M: linked-assoc >alist
    dlist>> dlist>sequence ;

M: linked-assoc clear-assoc
    [ assoc>> clear-assoc ] [ dlist>> clear-deque ] bi ;

M: linked-assoc clone 
    [ assoc>> clone ] [ dlist>> clone ] bi
    linked-assoc boa ;

INSTANCE: linked-assoc assoc
