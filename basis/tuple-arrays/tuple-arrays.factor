! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
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

FUNCTOR: tuple-array ( class: existing-class -- ) [[
    USING: accessors arrays classes.tuple.private kernel sequences
    sequences.private tuple-arrays.private ;

    TUPLE: ${class}-array
    { seq array read-only }
    { n array-capacity read-only }
    { length array-capacity read-only } ;

    INSTANCE: ${class}-array sequence

    : <${class}-array> ( length -- tuple-array )
        [ \ ${class} [ initial-values <repetition> concat ] [ tuple-arity ] bi ] keep
        \ ${class}-array boa ; inline

    M: ${class}-array length length>> ; inline

    M: ${class}-array nth-unsafe tuple-slice \ ${class} read-tuple ; inline

    M: ${class}-array set-nth-unsafe tuple-slice \ ${class} write-tuple ; inline

    M: ${class}-array new-sequence drop <${class}-array> ; inline

    : >${class}-array ( seq -- tuple-array ) 0 <${class}-array> clone-like ;

    M: ${class}-array like drop dup ${class}-array? [ >${class}-array ] unless ; inline
]]
