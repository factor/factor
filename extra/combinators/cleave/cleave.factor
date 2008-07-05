
USING: kernel combinators quotations arrays sequences locals macros
       shuffle combinators.lib ;

IN: combinators.cleave

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: [ncleave] ( SEQ N -- quot )
   SEQ [ [ N nkeep ] curry ] map concat [ N ndrop ] append >quotation ;

MACRO: ncleave ( seq n -- quot ) [ncleave] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Cleave into array
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: words quotations fry arrays.lib ;

: >quot ( obj -- quot ) dup word? [ 1quotation ] when ;

: >quots ( seq -- seq ) [ >quot ] map ;

MACRO: <arr> ( seq -- )
  [ >quots ] [ length ] bi
 '[ , cleave , narray ] ;

MACRO: <2arr> ( seq -- )
  [ >quots ] [ length ] bi
 '[ , 2cleave , narray ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: {1} ( x     -- {x}     ) 1array ; inline
: {2} ( x y   -- {x,y}   ) 2array ; inline
: {3} ( x y z -- {x,y,z} ) 3array ; inline

: {n} narray ;

: {bi}  ( x p q   -- {p(x),q(x)}      ) bi  {2} ; inline

: {tri} ( x p q r -- {p(x),q(x),r(x)} ) tri {3} ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Spread into array
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: <arr*> ( seq -- )
  [ >quots ] [ length ] bi
 '[ , spread , narray ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: {bi*}  ( x y p q     -- {p(x),q(y)}      ) bi*  {2} ; inline
: {tri*} ( x y z p q r -- {p(x),q(y),r(z)} ) tri* {3} ; inline
