! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel namespaces ;
IN: namespaces.extras

ERROR: variable-required variable ;

: required ( symbol -- obj )
    [ get ] [ variable-required ] ?unless ;

: 2required ( symbol1 symbol2 -- obj1 obj2 ) [ required ] bi@ ; inline
: 2get ( symbol1 symbol2 -- obj1 obj2 ) [ get ] bi@ ; inline

: xor* ( obj1 obj2 -- xor first? )
    [ swap [ 2drop f f ] [ f ] if* ]
    [ [ t ] [ f f ] if* ] if* ; inline

ERROR: one-variable-only symbol1 symbol2 value1 value2 ;

: one-of ( symbol1 symbol2 -- obj1/obj2 first? )
    2dup [ get ] bi@ 2dup xor* over
    [ [ 4drop ] 2dip ] [ one-variable-only ] if ;
