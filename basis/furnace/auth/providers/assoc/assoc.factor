! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel furnace.auth.providers ;
IN: furnace.auth.providers.assoc

TUPLE: users-in-memory assoc ;

: <users-in-memory> ( -- provider )
    H{ } clone users-in-memory boa ;

M: users-in-memory get-user ( username provider -- user/f )
    assoc>> at ;

M: users-in-memory update-user ( user provider -- ) 2drop ;

M: users-in-memory new-user ( user provider -- user/f )
    [ dup username>> ] dip assoc>>
    2dup key? [ 3drop f ] [ pick [ set-at ] dip ] if ;
