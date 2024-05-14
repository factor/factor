! Copyright (C) 2009 Jason W. Merrill.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.smart compiler.units
effects generalizations help help.markup kernel make math
sequences vocabs words ;

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
MACRO: duals>nweave ( n -- quot )
    dup dup dup
    '[
        [ [ epsilon-part>> ] _ napply ] _ nkeep
        [ ordinary-part>> ] _ napply _ nweave
    ] ;

MACRO: chain-rule ( word -- e )
    [ input-length '[ _ duals>nweave ] ]
    [ "derivative" word-prop ]
    [ input-length 1 + '[ _ nspread ] ]
    tri
    '[ [ @ _ @ ] sum-outputs ] ;

: set-dual-help ( dword word -- )
    [
        [
            stack-effect [ in>> ] [ out>> ] bi append
            [ dual ] map>alist { $values } prepend
        ] [
            [
                { $description } % "Version of " ,
                { $link } swap suffix ,
                " extended to work on dual numbers." ,
            ] { } make
        ] bi* 2array
    ] keepd set-word-help ;

PRIVATE>

MACRO: dual-op ( word -- quot )
    [ '[ _ ordinary-op ] ]
    [ input-length '[ _ nkeep ] ]
    [ '[ _ chain-rule ] ]
    tri
    '[ _ @ @ <dual> ] ;

: define-dual ( word -- )
    [ name>> "d" prepend "math.dual" create-word ] keep
    [ stack-effect set-stack-effect ]
    [ set-dual-help ]
    [ '[ _ dual-op ] define ]
    2tri ;

! Specialize math functions to operate on dual numbers.
[ all-words [ "derivative" word-prop ] filter
[ define-dual ] each ] with-compilation-unit
