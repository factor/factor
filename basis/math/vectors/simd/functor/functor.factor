! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types byte-arrays classes functors
kernel math parser prettyprint.custom sequences
sequences.private ;
IN: math.vectors.simd.functor

ERROR: bad-length got expected ;

FUNCTOR: define-simd-type ( T N -- )

A            DEFINES-CLASS ${N}${T}-array
<A>          DEFINES <${A}>
(A)          DEFINES (${A})
>A           DEFINES >${A}
A{           DEFINES ${A}{

NTH          [ T dup c-type-getter-boxer array-accessor ]
SET-NTH      [ T dup c-setter array-accessor ]

BYTES        [ T heap-size N * ]
INITIAL      [ BYTES <byte-array> ]

WHERE

TUPLE: A
{ underlying byte-array read-only initial: INITIAL } ;

: <A> ( -- simd-array ) BYTES <byte-array> A boa ; inline

: (A) ( -- simd-array ) BYTES (byte-array) A boa ; inline

M: A clone underlying>> clone \ A boa ; inline

M: A length drop N ; inline

M: A nth-unsafe underlying>> NTH call ; inline

M: A set-nth-unsafe underlying>> SET-NTH call ; inline

: >A ( seq -- simd-array ) \ A new clone-like ;

M: A like drop dup \ A instance? [ >A ] unless ; inline

M: A new-sequence drop dup N = [ drop (A) ] [ N bad-length ] if ; inline

M: A equal? over \ A instance? [ sequence= ] [ 2drop f ] if ;

M: A byte-length underlying>> length ; inline

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

SYNTAX: A{ \ } [ >A ] parse-literal ;

INSTANCE: A sequence

;FUNCTOR
