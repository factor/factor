! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel furnace.auth.providers ;
IN: furnace.auth.providers.assoc

TUPLE: users-in-memory assoc ;

: <users-in-memory> ( -- provider )
    H{ } clone users-in-memory boa ;

M: users-in-memory get-user assoc>> at ;

M: users-in-memory update-user 2drop ;

M: users-in-memory new-user
    [ dup username>> ] dip assoc>>
    2dup key? [ 3drop f ] [ pick [ set-at ] dip ] if ;
