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

: ptr-pass-through ( obj quot -- alien )
    over c-ptr? [ drop ] [ call ] if ; inline

: malloc-underlying ( obj -- alien )
    underlying>> malloc-byte-array ;

FUNCTOR: define-primitive-marshallers ( TYPE -- )
<TYPE> IS <${TYPE}>
>TYPE-array IS >${TYPE}-array
marshall-TYPE DEFINES marshall-${TYPE}
(marshall-TYPE*) DEFINES (marshall-${TYPE}*)
(marshall-TYPE**) DEFINES (marshall-${TYPE}**)
marshall-TYPE* DEFINES marshall-${TYPE}*
marshall-TYPE** DEFINES marshall-${TYPE}**
marshall-TYPE*-free DEFINES marshall-${TYPE}*-free
marshall-TYPE**-free DEFINES marshall-${TYPE}**-free
WHERE
: marshall-TYPE ( n -- byte-array )
    [ bool>arg ] ptr-pass-through ;
: (marshall-TYPE*) ( n/seq -- alien )
    [ <TYPE> malloc-byte-array ]
    [ >TYPE-array malloc-underlying ]
    marshall-x* ;
: (marshall-TYPE**) ( seq -- alien )
    [ >TYPE-array malloc-underlying ]
    map >void*-array malloc-underlying ;
: marshall-TYPE* ( n/seq -- alien )
    [ (marshall-TYPE*) ] ptr-pass-through ;
: marshall-TYPE** ( seq -- alien )
    [ (marshall-TYPE**) ] ptr-pass-through ;
: marshall-TYPE*-free ( n/seq -- alien )
    [ (marshall-TYPE*) &free ] ptr-pass-through ;
: marshall-TYPE**-free ( seq -- alien )
    [ (marshall-TYPE**) &free ] ptr-pass-through ;
;FUNCTOR

SYNTAX: PRIMITIVE-MARSHALLERS:
";" parse-tokens [ define-primitive-marshallers ] each ;
