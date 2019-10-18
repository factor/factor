! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays math vectors locals ;
IN: hash2

! Little ad-hoc datastructure used to map two numbers
! to a single value.
! Created for the NFC mapping table.
! We could use a hashtable of 2arrays, but that
! involves creating too many objects.
! Does not allow duplicate keys.

: hashcode2 ( a b -- hashcode )
    swap 8 shift + ; inline

: <hash2> ( size -- hash2 ) f <array> ;

: 2= ( a b pair -- ? )
    first2 [ = ] bi-curry@ bi* and ; inline

: (assoc2) ( a b alist -- {a,b,val} )
    [ 2= ] with with find nip ; inline

: assoc2 ( a b alist -- value )
    (assoc2) dup [ third ] when ; inline

:: set-assoc2 ( value a b alist -- alist )
    { a b value } alist ?push ; inline

: hash2@ ( a b hash2 -- a b bucket hash2 )
    [ 2dup hashcode2 ] dip [ length mod ] keep ; inline

: hash2 ( a b hash2 -- value/f )
    hash2@ nth dup [ assoc2 ] [ 3drop f ] if ;

:: set-hash2 ( a b value hash2 -- )
    value a b hash2 hash2@ [ set-assoc2 ] change-nth ;

: alist>hash2 ( alist size -- hash2 )
    <hash2> [ over [ first3 ] dip set-hash2 ] reduce ; inline
