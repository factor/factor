! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: kernel sequences ;

: assoc? ( list -- ? )
    #! Push if the list appears to be an alist. An association
    #! list is a list of conses where the car of each cons is a
    #! key, and the cdr is a value.
    dup list? [ [ cons? ] all? ] [ drop f ] ifte ;

: assoc* ( key alist -- [[ key value ]] )
    #! Look up a key/value pair.
    [ car = ] find-with nip ;

: assoc ( key alist -- value ) assoc* cdr ;

: assq* ( key alist -- [[ key value ]] )
    #! Looks up a key/value pair using identity comparison.
    [ car eq? ] find-with nip ;

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
