! Copyright (C) 2009 Jason W. Merrill.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.derivatives accessors
    macros generic compiler.units words effects vocabs
    sequences arrays assocs generalizations fry make
    combinators.smart help help.markup ;

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
    [ input-length 1 + '[ _ nspread ] ]
    tri
    '[ [ @ _ @ ] sum-outputs ] ;

: set-dual-help ( word dword -- ) 
    [ swap
        [ stack-effect [ in>> ] [ out>> ] bi append 
            [ dual ] { } map>assoc { $values } prepend
        ]
        [ [ { $description } % "Version of " , 
                   { $link } swap suffix , 
                   " extended to work on dual numbers." , ] 
            { } make
        ]
        bi* 2array
    ] keep set-word-help ;

PRIVATE>

MACRO: dual-op ( word -- )
    [ '[ _ ordinary-op ] ]
    [ input-length '[ _ nkeep ] ]
    [ '[ _ chain-rule ] ]
    tri
    '[ _ @ @ <dual> ] ;

: define-dual ( word -- )
    dup name>> "d" prepend "math.dual" create
    [ [ stack-effect ] dip set-stack-effect ]
    [ set-dual-help ]
    [ swap '[ _ dual-op ] define ]
    2tri ;

! Specialize math functions to operate on dual numbers.
[ all-words [ "derivative" word-prop ] filter
    [ define-dual ] each ] with-compilation-unit
