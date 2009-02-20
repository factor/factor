! Copyright (C) 2009 Jason W. Merrill.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.derivatives accessors
    macros words effects vocabs sequences generalizations fry
    combinators.smart generic compiler.units ;

IN: math.dual

TUPLE: dual ordinary-part epsilon-part ;

C: <dual> dual

! Ordinary numbers implement the dual protocol by returning 
! themselves as the ordinary part, and 0 as the epsilon part.
M: number ordinary-part>> ;

M: number epsilon-part>> drop 0 ;

: unpack-dual ( dual -- ordinary-part epsilon-part )
    [ ordinary-part>> ] [ epsilon-part>> ] bi ;

<PRIVATE

: input-length ( word -- n ) stack-effect in>> length ;

MACRO: ordinary-op ( word -- o )
    [ input-length ] keep
    '[ [ ordinary-part>> ] _ napply _ execute ] ;

! Takes N dual numbers <o1,e1> <o2,e2> ... <oN,eN> and weaves 
! their ordinary and epsilon parts to produce
! e1 o1 o2 ... oN e2 o1 o2 ... oN ... eN o1 o2 ... oN
! This allows a set of partial derivatives each to be evaluated 
! at the same point.
MACRO: duals>nweave ( n -- )
   dup dup dup
   '[
       [ [ epsilon-part>> ] _ napply ]
       _ nkeep
       [ ordinary-part>> ] _ napply
       _ nweave
    ] ;

MACRO: chain-rule ( word -- e )
    [ input-length '[ _ duals>nweave ] ]
    [ "derivative" word-prop ]
    [ input-length 1+ '[ _ nspread ] ]
    tri
    '[ [ @ _ @ ] sum-outputs ] ;

PRIVATE>

MACRO: dual-op ( word -- )
    [ '[ _ ordinary-op ] ]
    [ input-length '[ _ nkeep ] ]
    [ '[ _ chain-rule ] ]
    tri
    '[ _ @ @ <dual> ] ;

: define-dual ( word -- )
    [ 
        [ stack-effect ] 
        [ name>> "d" prepend "math.dual" create ]
        bi [ set-stack-effect ] keep
    ]
    keep
    '[ _ dual-op ] define ;

! Specialize math functions to operate on dual numbers.
[ all-words [ "derivative" word-prop ] filter
    [ define-dual ] each ] with-compilation-unit