! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private kernel words classes
math alien alien.c-types byte-arrays accessors
specialized-arrays ;
IN: specialized-arrays.direct.functor

FUNCTOR: define-direct-array ( T -- )

A'      IS ${T}-array
>A'     IS >${T}-array
<A'>    IS <${A'}>

A       DEFINES direct-${T}-array
<A>     DEFINES <${A}>

NTH     [ T dup c-getter array-accessor ]
SET-NTH [ T dup c-setter array-accessor ]

WHERE

TUPLE: A
{ underlying c-ptr read-only }
{ length fixnum read-only } ;

: <A> ( alien len -- direct-array ) A boa ; inline
M: A length length>> ;
M: A nth-unsafe underlying>> NTH call ;
M: A set-nth-unsafe underlying>> SET-NTH call ;
M: A like drop dup A instance? [ >A' ] unless ;
M: A new-sequence drop <A'> ;

INSTANCE: A sequence

;FUNCTOR
