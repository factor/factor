! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.auth.providers.assoc
USING: new-slots accessors assocs kernel
http.server.auth.providers ;

TUPLE: in-memory assoc ;

: <in-memory> ( -- provider )
    H{ } clone in-memory construct-boa ;

M: in-memory get-user ( username provider -- user/f )
    assoc>> at ;

M: in-memory update-user ( user provider -- ) 2drop ;

M: in-memory new-user ( user provider -- user/f )
    >r dup username>> r> assoc>>
    2dup key? [ 3drop f ] [ pick >r set-at r> ] if ;
