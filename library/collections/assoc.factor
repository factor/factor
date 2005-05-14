! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: kernel sequences ;

! An association list is a list of conses where the car of each
! cons is a key, and the cdr is a value. See the Factor
! Developer's Guide for details.

: assoc? ( list -- ? )
    #! Push if the list appears to be an alist.
    dup list? [ [ cons? ] all? ] [ drop f ] ifte ;

: assoc* ( key alist -- [[ key value ]] )
    #! Look up a key/value pair.
    [ car = ] some-with?  car ;

: assoc ( key alist -- value ) assoc* cdr ;

: assq* ( key alist -- [[ key value ]] )
    #! Looks up a key/value pair using identity comparison.
    [ car eq? ] some-with?  car ;

: assq ( key alist -- value ) assq* cdr ;

: remove-assoc ( key alist -- alist )
    #! Remove all key/value pairs with this key.
    [ car = not ] subset-with ;

: acons ( value key alist -- alist )
    #! Adds the key/value pair to the alist. Existing pairs with
    #! this key are not removed; the new pair simply shadows
    #! existing pairs.
    >r swons r> cons ;

: set-assoc ( value key alist -- alist )
    #! Adds the key/value pair to the alist.
    dupd remove-assoc acons ;

: assoc-apply ( value-alist quot-alist -- )
    #! Looks up the key of each pair in the first list in the
    #! second list to produce a quotation. The quotation is
    #! applied to the value of the pair. If there is no
    #! corresponding quotation, the value is popped off the
    #! stack.
    swap [
        unswons rot assoc* dup [ cdr call ] [ 2drop ] ifte
    ] each-with ;

: 2cons ( car1 car2 cdr1 cdr2 -- cons1 cons2 )
    rot swons >r cons r> ;

: zip ( list list -- list )
    #! Make a new list containing pairs of corresponding
    #! elements from the two given lists.
    2dup and [ 2uncons zip >r cons r> cons ] [ 2drop [ ] ] ifte ;

: unzip ( assoc -- keys values )
    #! Split an association list into two lists of keys and
    #! values.
    [ uncons >r uncons r> unzip 2cons ] [ [ ] [ ] ] ifte* ;
