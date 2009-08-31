! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private prettyprint.custom
kernel words classes math math.vectors.specialization parser
alien.c-types byte-arrays accessors summary ;
IN: specialized-arrays.functor

ERROR: bad-byte-array-length byte-array type ;

M: bad-byte-array-length summary
    drop "Byte array length doesn't divide type width" ;

: (underlying) ( n c-type -- array )
    heap-size * (byte-array) ; inline

: <underlying> ( n type -- array )
    heap-size * <byte-array> ; inline

FUNCTOR: define-array ( T -- )

A            DEFINES-CLASS ${T}-array
S            DEFINES-CLASS ${T}-sequence
<A>          DEFINES <${A}>
(A)          DEFINES (${A})
>A           DEFINES >${A}
byte-array>A DEFINES byte-array>${A}
A{           DEFINES ${A}{

NTH          [ T dup c-type-getter-boxer array-accessor ]
SET-NTH      [ T dup c-setter array-accessor ]

WHERE

MIXIN: S

TUPLE: A
{ length array-capacity read-only }
{ underlying byte-array read-only } ;

: <A> ( n -- specialized-array ) dup T <underlying> A boa ; inline

: (A) ( n -- specialized-array ) dup T (underlying) A boa ; inline

: byte-array>A ( byte-array -- specialized-array )
    dup length T heap-size /mod 0 = [ drop T bad-byte-array-length ] unless
    swap A boa ; inline

M: A clone [ length>> ] [ underlying>> clone ] bi A boa ; inline

M: A length length>> ; inline

M: A nth-unsafe underlying>> NTH call ; inline

M: A set-nth-unsafe underlying>> SET-NTH call ; inline

: >A ( seq -- specialized-array ) A new clone-like ;

M: A like drop dup A instance? [ >A ] unless ; inline

M: A new-sequence drop (A) ; inline

M: A equal? over A instance? [ sequence= ] [ 2drop f ] if ;

M: A resize
    [ drop ] [
        [ T heap-size * ] [ underlying>> ] bi*
        resize-byte-array
    ] 2bi
    A boa ; inline

M: A byte-length underlying>> length ; inline

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

SYNTAX: A{ \ } [ >A ] parse-literal ;

INSTANCE: A sequence
INSTANCE: A S

A T c-type-boxed-class specialize-vector-words

T c-type
    \ A >>array-class
    \ <A> >>array-constructor
    \ (A) >>(array)-constructor
    \ S >>sequence-mixin-class
    drop

;FUNCTOR
