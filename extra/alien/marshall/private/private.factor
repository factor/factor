! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.inline arrays
combinators fry functors kernel lexer libc macros math
sequences specialized-arrays libc.private
combinators.short-circuit alien.data ;
SPECIALIZED-ARRAY: void*
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
    over { [ c-ptr? ] [ ] } 1&& [ drop ] [ call ] if ; inline

: malloc-underlying ( obj -- alien )
    underlying>> malloc-byte-array ;

FUNCTOR: define-primitive-marshallers ( TYPE -- )
<TYPE> IS <${TYPE}>
*TYPE IS *${TYPE}
>TYPE-array IS >${TYPE}-array
marshall-TYPE DEFINES marshall-${TYPE}
(marshall-TYPE*) DEFINES (marshall-${TYPE}*)
(marshall-TYPE**) DEFINES (marshall-${TYPE}**)
marshall-TYPE* DEFINES marshall-${TYPE}*
marshall-TYPE** DEFINES marshall-${TYPE}**
marshall-TYPE*-free DEFINES marshall-${TYPE}*-free
marshall-TYPE**-free DEFINES marshall-${TYPE}**-free
unmarshall-TYPE* DEFINES unmarshall-${TYPE}*
unmarshall-TYPE*-free DEFINES unmarshall-${TYPE}*-free
WHERE
<PRIVATE
: (marshall-TYPE*) ( n/seq -- alien )
    [ <TYPE> malloc-byte-array ]
    [ >TYPE-array malloc-underlying ]
    marshall-x* ;
PRIVATE>
: marshall-TYPE* ( n/seq -- alien )
    [ (marshall-TYPE*) ] ptr-pass-through ;
<PRIVATE
: (marshall-TYPE**) ( seq -- alien )
    [ marshall-TYPE* ] void*-array{ } map-as malloc-underlying ;
PRIVATE>
: marshall-TYPE** ( seq -- alien )
    [ (marshall-TYPE**) ] ptr-pass-through ;
: unmarshall-TYPE* ( alien -- n )
    *TYPE ; inline
: unmarshall-TYPE*-free ( alien -- n )
    [ unmarshall-TYPE* ] keep add-malloc free ;
;FUNCTOR

SYNTAX: PRIMITIVE-MARSHALLERS:
";" parse-tokens [ define-primitive-marshallers ] each ;
