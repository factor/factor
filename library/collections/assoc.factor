! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: kernel sequences ;

: assoc* ( key alist -- [[ key value ]] )
    #! Look up a key/value pair.
    [ car = ] find-with nip ;

: assoc ( key alist -- value ) assoc* cdr ;

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
