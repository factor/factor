! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private prettyprint.custom
kernel words classes math parser alien.c-types byte-arrays
accessors summary ;
IN: specialized-arrays.functor

ERROR: bad-byte-array-length byte-array type ;

M: bad-byte-array-length summary
    drop "Byte array length doesn't divide type width" ;

: (c-array) ( n c-type -- array )
    heap-size * (byte-array) ; inline

FUNCTOR: define-array ( T -- )

A            DEFINES-CLASS ${T}-array
<A>          DEFINES <${A}>
(A)          DEFINES (${A})
>A           DEFINES >${A}
byte-array>A DEFINES byte-array>${A}
A{           DEFINES ${A}{

NTH          [ T dup c-getter array-accessor ]
SET-NTH      [ T dup c-setter array-accessor ]

WHERE

TUPLE: A
{ length array-capacity read-only }
{ underlying byte-array read-only } ;

: <A> ( n -- specialized-array ) dup T <c-array> A boa ; inline

: (A) ( n -- specialized-array ) dup T (c-array) A boa ; inline

: byte-array>A ( byte-array -- specialized-array )
    dup length T heap-size /mod 0 = [ drop T bad-byte-array-length ] unless
    swap A boa ; inline

M: A clone [ length>> ] [ underlying>> clone ] bi A boa ;

M: A length length>> ;

M: A nth-unsafe underlying>> NTH call ;

M: A set-nth-unsafe underlying>> SET-NTH call ;

: >A ( seq -- specialized-array ) A new clone-like ; inline

M: A like drop dup A instance? [ >A ] unless ;

M: A new-sequence drop (A) ;

M: A equal? over A instance? [ sequence= ] [ 2drop f ] if ;

M: A resize
    [ drop ] [
        [ T heap-size * ] [ underlying>> ] bi*
        resize-byte-array
    ] 2bi
    A boa ;

M: A byte-length underlying>> length ;

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

: A{ \ } [ >A ] parse-literal ; parsing

INSTANCE: A sequence

;FUNCTOR
