USING: kernel sequences arrays math vectors ;
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
    first2 swapd >r >r = r> r> = and ; inline

: (assoc2) ( a b alist -- {a,b,val} )
    [ >r 2dup r> 2= ] find >r 3drop r> ; inline

: assoc2 ( a b alist -- value )
    (assoc2) dup [ third ] when ; inline

: set-assoc2 ( value a b alist -- alist )
    >r rot 3array r> ?push ; inline

: hash2@ ( a b hash2 -- a b bucket hash2 )
    >r 2dup hashcode2 r> [ length mod ] keep ; inline

: hash2 ( a b hash2 -- value/f )
    hash2@ nth [ assoc2 ] [ 2drop f ] if* ;

: set-hash2 ( a b value hash2 -- )
    >r -rot r> hash2@ [ set-assoc2 ] change-nth ;

: alist>hash2 ( alist size -- hash2 )
    <hash2> [ over >r first3 r> set-hash2 ] reduce ; inline
