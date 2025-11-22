! Copyright (C) 2025 Serre
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs effects kernel math reverse
math.functions sequences stack-checker quotations variants ;
IN: monadics

! === An alternative implementation of Haskell-style monadic
! and applicative programming techniques.
! Possible TODOs:
!   More Classes? (R/W/S? Traversables? Contra/Profunctors?)
!   More Utils? (Monadic Loops? MapM? <* and *>?)
!   Unit Tests confirming Functor/Monad Laws.
!       * (Need a better pure instance?)

: id ( x -- x ) ;

! == Functors
GENERIC#: fmap 
   1 ( M-x quot -- M-y )

: $> ( M-x a -- M-x )   
   '[ drop _ ] fmap ;

! == Applicatives
: lift ( quot M-x -- M-y )
   swap flip-quot fmap ;
ALIAS: <$> lift

GENERIC#: pure 
   1 ( M-a x -- M-a M-x )

GENERIC#: reify
   1 ( M-quot M-x -- M-y )
ALIAS: <*> reify

! == Alternatives
GENERIC#: choose 
   1 ( M-x M-x -- M-x )
ALIAS: <|> choose

! == Monads
GENERIC#: and-then 
   1 ( M-x quot: ( x -- M-y ) -- M-y )
ALIAS: >>= and-then 

: >> ( M-x M-y -- M-y )
   '[ drop _ ] >>= ;

: monad-join ( M-M-x -- M-x ) [ ] >>= ;
   
! == Lazy evaluation
: lazy-call ( value quot -- value/curried )
   curry 
      dup infer { } { "x" } <effect> =
   [ call( -- x ) ] when ;

! == Explicit Maybe Monad 
! (Could extend value/f pattern to all objects.)
VARIANT: Maybe
   Just: { value }
   Nothing ;
C: just Just

M: Maybe fmap ( M-x quot -- M-y )
   over Just? [ [ value>> ] dip
                lazy-call just ] 
              [ drop ] if ;

M: Maybe choose ( M-x M-x -- M-x )
   dup Nothing? [ drop ] [ nip ] if ;

M: Maybe pure ( M-a x -- M-a M-x ) just ;

M: Maybe reify ( M-quot M-x -- M-y )
   2dup [ Just? ] bi@ and
      [ [ value>> ] bi@ swap lazy-call just ]
      [ 2drop Nothing ] if ;

: (maybe-join) ( M-M-x -- M-x )
   [ Just? ] 1guard [ value>> ] [ Nothing ] if* ;

M: Maybe and-then ( M-x quot: ( x -- M-y ) -- M-y )
   fmap (maybe-join) ;

! = Maybe Utilities
: >maybe ( value/f -- Maybe ) 
   [ just ] [ Nothing ] if* ; inline

: guard-maybe ( value quot: ( a -- bool ) -- Maybe )
   1guard >maybe ; inline

! == Either Monad, by convention Right is a valid value,
! while Left encodes an error value. Any action over an
! error preserves the error.
!   (Exception Monad for concat'ing multiple errors?)
VARIANT: Either
    Left: { value }
   Right: { value } ;
C:  left Left
C: right Right

M: Either fmap ( M-x quot -- M-y )
   over Right? [ [ value>> ] dip
                lazy-call right ] 
               [ drop ] if ;
M: Either pure ( M-a x -- M-a M-x ) right ;

M: Either reify ( M-quot M-x -- M-y )
   2dup [ Right? ] bi@ and
      [ [ value>> ] bi@ swap lazy-call right ]
      [ dup Left? [ nip ] [ drop ] if ]
   if ;

M: Either choose ( M-x M-x -- M-x )
   dup Right? [ drop ] [ nip ] if ;

M: Either and-then ( M-x quot: ( x -- M-y ) -- M-y )
   over Right? [ [ value>> ] dip lazy-call ]
               [ drop ] if ;

! = Either Utilities
: ?either ( x left pred -- Either-x )
   overd call [ drop right ] [ nip left ] if ; inline

: validate ( x pairs -- Either-x )
! Predicates of form { "Error" [ predicate? ] }
   [ first2 [ ?either ] 2curry ] map
   swap right [ and-then ] reduce ;

! == Sequences
M: sequence fmap ( xs quot -- ys )
  [ lazy-call ] curry map ;

M: sequence pure 1array ;

M: sequence reify ( quots xs -- ys )
   swap zip [ lazy-call ] { } assoc>map ;

M: sequence and-then ( xs quot: ( x -- ys ) -- ys )
   fmap concat ;
