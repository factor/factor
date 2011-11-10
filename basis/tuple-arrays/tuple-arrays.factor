! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.smart fry functors kernel
kernel.private macros sequences combinators sequences.private
stack-checker parser math classes.tuple classes.tuple.private ;
FROM: inverse => undo ;
IN: tuple-arrays

ERROR: not-final class ;

<PRIVATE

MACRO: boa-unsafe ( class -- quot ) tuple-layout '[ _ <tuple-boa> ] ;

: tuple-arity ( class -- quot ) '[ _ boa ] inputs ; inline

: smart-tuple>array ( tuple class -- array )
    '[ [ _ boa ] undo ] output>array ; inline

: tuple-prototype ( class -- array )
    [ new ] [ smart-tuple>array ] bi ; inline

: tuple-slice ( n seq -- slice )
    [ n>> [ * dup ] keep + ] [ seq>> ] bi <slice-unsafe> ; inline

: read-tuple ( slice class -- tuple )
    '[ _ boa-unsafe ] input<sequence-unsafe ; inline

MACRO: write-tuple ( class -- quot )
    [ '[ [ _ boa ] undo ] ]
    [ tuple-arity iota <reversed> [ '[ [ _ ] dip set-nth-unsafe ] ] map '[ _ cleave ] ]
    bi '[ _ dip @ ] ;

: check-final ( class -- )
    {
        { [ dup tuple-class? not ] [ not-a-tuple ] }
        { [ dup final-class? not ] [ not-final ] }
        [ drop ]
    } cond ;

PRIVATE>

FUNCTOR: define-tuple-array ( CLASS -- )

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
    [ \ CLASS [ tuple-prototype <repetition> concat ] [ tuple-arity ] bi ] keep
    \ CLASS-array boa ; inline

M: CLASS-array length length>> ; inline

M: CLASS-array nth-unsafe tuple-slice \ CLASS read-tuple ; inline

M: CLASS-array set-nth-unsafe tuple-slice \ CLASS write-tuple ; inline

M: CLASS-array new-sequence drop <CLASS-array> ; inline

: >CLASS-array ( seq -- tuple-array ) 0 <CLASS-array> clone-like ;

M: CLASS-array like drop dup CLASS-array? [ >CLASS-array ] unless ; inline

INSTANCE: CLASS-array sequence

;FUNCTOR

SYNTAX: TUPLE-ARRAY: scan-word define-tuple-array ;
