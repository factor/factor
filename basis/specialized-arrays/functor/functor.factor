! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private prettyprint.custom
kernel words classes math math.vectors.specialization parser
alien.c-types byte-arrays accessors summary alien specialized-arrays ;
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
<direct-A>   DEFINES <direct-${A}>
>A           DEFINES >${A}
byte-array>A DEFINES byte-array>${A}

A{           DEFINES ${A}{
A@           DEFINES ${A}@

NTH          [ T dup c-type-getter-boxer array-accessor ]
SET-NTH      [ T dup c-setter array-accessor ]

WHERE

MIXIN: S

TUPLE: A
{ underlying c-ptr read-only }
{ length array-capacity read-only } ;

: <direct-A> ( alien len -- specialized-array ) A boa ; inline

: <A> ( n -- specialized-array ) [ T <underlying> ] keep <direct-A> ; inline

: (A) ( n -- specialized-array ) [ T (underlying) ] keep <direct-A> ; inline

: byte-array>A ( byte-array -- specialized-array )
    dup length T heap-size /mod 0 = [ drop T bad-byte-array-length ] unless
    <direct-A> ; inline

M: A clone [ underlying>> clone ] [ length>> ] bi <direct-A> ; inline

M: A length length>> ; inline

M: A nth-unsafe underlying>> NTH call ; inline

M: A set-nth-unsafe underlying>> SET-NTH call ; inline

: >A ( seq -- specialized-array ) A new clone-like ;

M: A like drop dup A instance? [ >A ] unless ; inline

M: A new-sequence drop (A) ; inline

M: A equal? over A instance? [ sequence= ] [ 2drop f ] if ;

M: A resize
    [
        [ T heap-size * ] [ underlying>> ] bi*
        resize-byte-array
    ] [ drop ] 2bi
    <direct-A> ; inline

M: A byte-length underlying>> length ; inline
M: A pprint-delims drop \ A{ \ } ;
M: A >pprint-sequence ;

SYNTAX: A{ \ } [ >A ] parse-literal ;
SYNTAX: A@ scan-object scan-object <direct-A> parsed ;

INSTANCE: A specialized-array

A T c-type-boxed-class f specialize-vector-words

T c-type
    \ A >>array-class
    \ <A> >>array-constructor
    \ (A) >>(array)-constructor
    \ <direct-A> >>direct-array-constructor
    drop

;FUNCTOR
