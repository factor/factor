! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private
prettyprint.backend kernel words classes math parser
alien.c-types byte-arrays accessors ;
IN: specialized-arrays.functor

FUNCTOR: define-array ( T -- )

A       DEFINES ${T}-array
<A>     DEFINES <${A}>
>A      DEFINES >${A}
A{      DEFINES ${A}{

NTH     [ T dup c-getter array-accessor ]
SET-NTH [ T dup c-setter array-accessor ]

WHERE

TUPLE: A
{ length array-capacity read-only }
{ underlying byte-array read-only } ;

: <A> dup T <c-array> A boa ; inline

M: A clone [ length>> ] [ underlying>> clone ] bi A boa ;

M: A length length>> ;

M: A nth-unsafe underlying>> NTH call ;

M: A set-nth-unsafe underlying>> SET-NTH call ;

: >A A new clone-like ; inline

M: A like drop dup A instance? [ >A execute ] unless ;

M: A new-sequence drop <A> execute ;

M: A equal? over A instance? [ sequence= ] [ 2drop f ] if ;

M: A resize
    [ drop ] [
        [ T heap-size * ] [ underlying>> ] bi*
        resize-byte-array
    ] 2bi
    A boa ;

M: A byte-length underlying>> length ;

M: A pprint-delims drop A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

: A{ \ } [ >A execute ] parse-literal ; parsing

INSTANCE: A sequence

;FUNCTOR
