! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types byte-arrays classes functors
kernel math parser prettyprint.custom sequences
sequences.private literals ;
IN: math.vectors.simd.functor

ERROR: bad-length got expected ;

FUNCTOR: define-simd-128 ( T -- )

T-TYPE       IS ${T}

N            [ 16 T-TYPE heap-size /i ]

A            DEFINES-CLASS ${T}-${N}
>A           DEFINES >${A}
A{           DEFINES ${A}{

NTH          [ T-TYPE dup c-type-getter-boxer array-accessor ]
SET-NTH      [ T-TYPE dup c-setter array-accessor ]

A-rep        IS ${A}-rep
A-vv->v-op   DEFINES-PRIVATE ${A}-vv->v-op
A-v->n-op    DEFINES-PRIVATE ${A}-v->n-op

WHERE

TUPLE: A
{ underlying byte-array read-only initial: $[ 16 <byte-array> ] } ;

M: A clone underlying>> clone \ A boa ; inline

M: A length drop N ; inline

M: A nth-unsafe underlying>> NTH call ; inline

M: A set-nth-unsafe underlying>> SET-NTH call ; inline

: >A ( seq -- simd-array ) \ A new clone-like ;

M: A like drop dup \ A instance? [ >A ] unless ; inline

M: A new-sequence
    drop dup N =
    [ drop 16 <byte-array> \ A boa ]
    [ N bad-length ]
    if ; inline

M: A equal? over \ A instance? [ sequence= ] [ 2drop f ] if ;

M: A byte-length underlying>> length ; inline

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

SYNTAX: A{ \ } [ >A ] parse-literal ;

INSTANCE: A sequence

<PRIVATE

: A-vv->v-op ( v1 v2 quot -- v3 )
    [ [ underlying>> ] bi@ A-rep ] dip call \ A boa ; inline

: A-v->n-op ( v quot -- n )
    [ underlying>> A-rep ] dip call ; inline

PRIVATE>

;FUNCTOR

! Synthesize 256-bit vectors from a pair of 128-bit vectors
FUNCTOR: define-simd-256 ( T -- )

T-TYPE       IS ${T}

N            [ 32 T-TYPE heap-size /i ]

N/2          [ N 2 / ]
A/2          IS ${T}-${N/2}

A            DEFINES-CLASS ${T}-${N}
>A           DEFINES >${A}
A{           DEFINES ${A}{

A-deref      DEFINES-PRIVATE ${A}-deref

A-rep        IS ${A/2}-rep
A-vv->v-op   DEFINES-PRIVATE ${A}-vv->v-op
A-v->n-op    DEFINES-PRIVATE ${A}-v->n-op

WHERE

SLOT: underlying1
SLOT: underlying2

TUPLE: A
{ underlying1 byte-array initial: $[ 16 <byte-array> ] read-only }
{ underlying2 byte-array initial: $[ 16 <byte-array> ] read-only } ;

M: A clone
    [ underlying1>> clone ] [ underlying2>> clone ] bi
    \ A boa ; inline

M: A length drop N ; inline

: A-deref ( n seq -- n' seq' )
    over N/2 < [ underlying1>> ] [ [ N/2 - ] dip underlying2>> ] if \ A/2 boa ; inline

M: A nth-unsafe A-deref nth-unsafe ; inline

M: A set-nth-unsafe A-deref set-nth-unsafe ; inline

: >A ( seq -- simd-array ) \ A new clone-like ;

M: A like drop dup \ A instance? [ >A ] unless ; inline

M: A new-sequence
    drop dup N =
    [ drop 16 <byte-array> 16 <byte-array> \ A boa ]
    [ N bad-length ]
    if ; inline

M: A equal? over \ A instance? [ sequence= ] [ 2drop f ] if ;

M: A byte-length drop 32 ; inline

SYNTAX: A{ \ } [ >A ] parse-literal ;

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

INSTANCE: A sequence

: A-vv->v-op ( v1 v2 quot -- v3 )
    [ [ [ underlying1>> ] bi@ A-rep ] dip call ]
    [ [ [ underlying2>> ] bi@ A-rep ] dip call ] 3bi
    \ A boa ; inline

: A-v->n-op ( v1 combine-quot reduce-quot -- v2 )
    [ [ [ underlying1>> ] [ underlying2>> ] bi A-rep ] dip call A-rep ]
    dip call ; inline

;FUNCTOR
