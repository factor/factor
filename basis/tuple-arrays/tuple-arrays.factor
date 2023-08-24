! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes classes.tuple
classes.tuple.private combinators combinators.smart fry functors
kernel macros math parser sequences sequences.private ;
FROM: inverse => undo ;
IN: tuple-arrays

ERROR: not-final class ;

<PRIVATE

MACRO: boa-unsafe ( class -- quot ) tuple-layout '[ _ <tuple-boa> ] ;

: tuple-arity ( class -- quot ) '[ _ boa ] inputs ; inline

: tuple-slice ( n seq -- slice )
    [ n>> [ * dup ] keep + ] [ seq>> ] bi <slice-unsafe> ; inline

: read-tuple ( slice class -- tuple )
    '[ _ boa-unsafe ] input<sequence-unsafe ; inline

MACRO: write-tuple ( class -- quot )
    [ '[ [ _ boa ] undo ] ]
    [ tuple-arity <iota> <reversed> [ '[ [ _ ] dip set-nth-unsafe ] ] map '[ _ cleave ] ]
    bi '[ _ dip @ ] ;

: check-final ( class -- )
    tuple-class check-instance
    dup final-class? [ drop ] [ not-final ] if ;

PRIVATE>

<FUNCTOR: define-tuple-array ( CLASS -- )

CLASS IS ${CLASS}

CLASS-array DEFINES-CLASS ${CLASS}-array
CLASS-array? IS ${CLASS-array}?

<CLASS-array> DEFINES <${CLASS}-array>
>CLASS-array DEFINES >${CLASS}-array

WHERE

CLASS check-final

TUPLE: CLASS-array
{ seq array read-only }
{ n array-capacity read-only }
{ length array-capacity read-only } ;

: <CLASS-array> ( length -- tuple-array )
    [ \ CLASS [ initial-values <repetition> concat ] [ tuple-arity ] bi ] keep
    \ CLASS-array boa ; inline

M: CLASS-array length length>> ; inline

M: CLASS-array nth-unsafe tuple-slice \ CLASS read-tuple ; inline

M: CLASS-array set-nth-unsafe tuple-slice \ CLASS write-tuple ; inline

M: CLASS-array new-sequence drop <CLASS-array> ; inline

: >CLASS-array ( seq -- tuple-array ) 0 <CLASS-array> clone-like ;

M: CLASS-array like drop dup CLASS-array? [ >CLASS-array ] unless ; inline

INSTANCE: CLASS-array sequence

;FUNCTOR>

SYNTAX: TUPLE-ARRAY: scan-word define-tuple-array ;
