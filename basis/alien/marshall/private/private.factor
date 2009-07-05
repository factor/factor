! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.inline arrays
combinators fry functors kernel lexer libc macros math
sequences specialized-arrays.alien ;
IN: alien.marshall.private

: bool>arg ( ? -- 1/0/obj )
    {
        { t [ 1 ] }
        { f [ 0 ] }
        [ ]
    } case ;

MACRO: marshall-x* ( num-quot seq-quot -- alien )
    '[ bool>arg dup number? _ _ if ] ;

: malloc-underlying ( obj -- alien )
    underlying>> malloc-byte-array ;

FUNCTOR: define-primitive-marshallers ( TYPE -- )
<TYPE> IS <${TYPE}>
>TYPE-array IS >${TYPE}-array
marshall-TYPE DEFINES marshall-${TYPE}
marshall-TYPE* DEFINES marshall-${TYPE}*
marshall-TYPE** DEFINES marshall-${TYPE}**
WHERE
: marshall-TYPE ( n -- byte-array )
    dup c-ptr? [ bool>arg ] unless ;
: marshall-TYPE* ( n/seq -- alien )
    dup c-ptr? [
        [ <TYPE> malloc-byte-array ]
        [ >TYPE-array malloc-underlying ]
        marshall-x* &free
    ] unless ;
: marshall-TYPE** ( seq -- alien )
    dup c-ptr? [
        [ >TYPE-array malloc-underlying ]
        map >void*-array malloc-underlying &free
    ] unless ;
;FUNCTOR

SYNTAX: PRIMITIVE-MARSHALLERS:
";" parse-tokens [ define-primitive-marshallers ] each ;
