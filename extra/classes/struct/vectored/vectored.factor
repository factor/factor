! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.struct classes.tuple combinators
functors kernel math parser quotations sequences
sequences.private slots specialized-arrays words ;
IN: classes.struct.vectored

<PRIVATE

: array-class-of ( type -- array-type )
    [ define-array-vocab ] [ name>> "-array" append swap lookup-word ] bi ;
: <array-class>-of ( type -- array-type )
    [ define-array-vocab ] [ name>> "<" "-array>" surround swap lookup-word ] bi ;
: (array-class)-of ( type -- array-type )
    [ define-array-vocab ] [ name>> "(" "-array)" surround swap lookup-word ] bi ;

: >vectored-slot ( struct-slot offset -- tuple-slot )
    {
        [ drop name>> ]
        [ nip ]
        [ drop type>> array-class-of dup initial-value drop ]
        [ 2drop t ]
    } 2cleave slot-spec boa ;

MACRO: first-slot ( struct-class -- quot: ( struct -- value ) )
    struct-slots first name>> reader-word 1quotation ;

MACRO: set-vectored-nth ( struct-class -- quot: ( value i vector -- ) )
    struct-slots [
        name>> reader-word 1quotation dup
        '[ _ [ ] _ tri* set-nth-unsafe ]
    ] map '[ _ 3cleave ] ;

MACRO: <vectored-slots> ( struct-class -- quot: ( n -- slots... ) )
    struct-slots [ type>> <array-class>-of 1quotation ] map
    '[ _ cleave ] ;

MACRO: (vectored-slots) ( struct-class -- quot: ( n -- slots... ) )
    struct-slots [ type>> (array-class)-of 1quotation ] map
    '[ _ cleave ] ;

MACRO: (vectored-element>) ( struct-class -- quot: ( elt -- struct ) )
    [ struct-slots [ name>> reader-word 1quotation ] map ] keep
    '[ _ cleave _ boa ] ;

SLOT: (n)
SLOT: (vectored)

<FUNCTOR: define-vectored-accessors ( S>> S<< T -- )

WHERE

M: T S>>
    [ (n)>> ] [ (vectored)>> S>> ] bi nth-unsafe ; inline
M: T S<<
    [ (n)>> ] [ (vectored)>> S>> ] bi set-nth-unsafe ; inline

;FUNCTOR>

PRIVATE>

GENERIC: struct-transpose ( structstruct -- ssttrruucctt )
GENERIC: vectored-element> ( elt -- struct )

<FUNCTOR: define-vectored-struct ( T -- )

T-array [ T array-class-of ]

vectored-T         DEFINES-CLASS vectored-${T}
vectored-T-element DEFINES-CLASS vectored-${T}-element

<vectored-T>       DEFINES <vectored-${T}>
(vectored-T)       DEFINES (vectored-${T})

WHERE

vectored-T tuple T struct-slots [ >vectored-slot ] map-index define-tuple-class

TUPLE: vectored-T-element
    { (n)        fixnum     read-only }
    { (vectored) vectored-T read-only } ;

T struct-slots [
    name>> [ reader-word ] [ writer-word ] bi
    vectored-T-element define-vectored-accessors
] each

M: vectored-T-element vectored-element>
    T (vectored-element>) ; inline

M: vectored-T nth-unsafe
    vectored-T-element boa ; inline

M: vectored-T length
    T first-slot length ; inline

M: vectored-T set-nth-unsafe
    T set-vectored-nth ; inline

INSTANCE: vectored-T sequence

: <vectored-T> ( n -- vectored-T )
    T <vectored-slots> vectored-T boa ; inline

: (vectored-T) ( n -- vectored-T )
    T (vectored-slots) vectored-T boa ; inline

M: vectored-T struct-transpose
    [ vectored-element> ] T-array new map-as ; inline

M: T-array struct-transpose
    dup length [ nip <iota> ] [ drop ] [ nip (vectored-T) ] 2tri
    [ [ [ nth ] [ set-nth ] bi-curry* bi ] 2curry each ] keep ; inline

;FUNCTOR>

SYNTAX: VECTORED-STRUCT:
    scan-word define-vectored-struct ;
