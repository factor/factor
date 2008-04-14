! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.auth.providers.assoc
USING: accessors assocs kernel
http.server.auth.providers ;

TUPLE: users-in-memory assoc ;

: <users-in-memory> ( -- provider )
    H{ } clone users-in-memory boa ;

M: users-in-memory get-user ( username provider -- user/f )
    assoc>> at ;

M: users-in-memory update-user ( user provider -- ) 2drop ;

M: users-in-memory new-user ( user provider -- user/f )
    >r dup username>> r> assoc>>
    2dup key? [ 3drop f ] [ pick >r set-at r> ] if ;
