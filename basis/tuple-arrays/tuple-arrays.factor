! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.smart fry functors grouping
kernel macros sequences sequences.private stack-checker
parser ;
FROM: inverse => undo ;
IN: tuple-arrays

<PRIVATE

MACRO: infer-in ( class -- quot ) infer in>> '[ _ ] ;

: smart-tuple>array ( tuple class -- array )
    '[ [ _ boa ] undo ] output>array ; inline

: smart-array>tuple ( array class -- tuple )
    '[ _ boa ] input<sequence ; inline

: tuple-arity ( class -- quot ) '[ _ boa ] infer-in ; inline

: tuple-prototype ( class -- array )
    [ new ] [ smart-tuple>array ] bi ; inline

PRIVATE>

FUNCTOR: define-tuple-array ( CLASS -- )

CLASS IS ${CLASS}

CLASS-array DEFINES-CLASS ${CLASS}-array
CLASS-array? IS ${CLASS-array}?

<CLASS-array> DEFINES <${CLASS}-array>
>CLASS-array DEFINES >${CLASS}-array

WHERE

TUPLE: CLASS-array { seq sliced-groups read-only } ;

: <CLASS-array> ( length -- tuple-array )
    CLASS tuple-prototype <repetition> concat
    CLASS tuple-arity <sliced-groups>
    CLASS-array boa ;

M: CLASS-array nth-unsafe
    seq>> nth-unsafe CLASS smart-array>tuple ;

M: CLASS-array set-nth-unsafe
    [ CLASS smart-tuple>array ] 2dip seq>> set-nth-unsafe ;

M: CLASS-array new-sequence
    drop <CLASS-array> ;

: >CLASS-array ( seq -- tuple-array )
    dup empty? [
        0 <CLASS-array> clone-like
    ] unless ;

M: CLASS-array like 
    drop dup CLASS-array? [ >CLASS-array ] unless ;

M: CLASS-array length seq>> length ;

INSTANCE: CLASS-array sequence

;FUNCTOR

SYNTAX: TUPLE-ARRAY: scan-word define-tuple-array ;
