! Copyright (C) 2009 Jason W. Merrill.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.derivatives accessors
    macros words effects sequences generalizations fry
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

: define-dual-method ( word -- )
    [ \ dual swap create-method ] keep '[ _ dual-op ] define ;

! Specialize math functions to operate on dual numbers.
[ { sqrt exp log sin cos tan sinh cosh tanh acos asin atan }
    [ define-dual-method ] each ] with-compilation-unit

! Inverse methods { asinh, acosh, atanh } are not generic, so
! there is no way to specialize them for dual numbers.  However,
! they are defined in terms of functions that can operate on
! dual numbers and arithmetic methods, so if it becomes
! possible to make arithmetic operators work directly on dual
! numbers, we will get these for free.

! Arithmetic words are not generic (yet?), so we have to 
! define special versions of them to operate on dual numbers.
: d+ ( x y -- x+y ) \ + dual-op ;
: d- ( x y -- x-y ) \ - dual-op ;
: d* ( x y -- x*y ) \ * dual-op ;
: d/ ( x y -- x/y ) \ / dual-op ;
: d^ ( x y -- x^y ) \ ^ dual-op ;

: dabs ( x -- |x| ) \ abs dual-op ;

! The following words are also not generic, but are defined in
! terms of words that can operate on dual numbers and
! arithmetic.  If it becomes possible to implement arithmetic on
! dual numbers directly, these functions can be deleted.
: dneg ( x -- -x ) \ neg dual-op ;
: drecip ( x -- 1/x ) \ recip dual-op ;
: dasinh ( x -- y ) \ asinh dual-op ;
: dacosh ( x -- y ) \ acosh dual-op ;
: datanh ( x -- y ) \ atanh dual-op ;