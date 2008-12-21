
USING: kernel combinators words quotations arrays sequences locals macros
       shuffle generalizations fry ;

IN: combinators.cleave

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: >quot ( obj -- quot ) dup word? [ 1quotation ] when ;

: >quots ( seq -- seq ) [ >quot ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: [ncleave] ( SEQ N -- quot )
   SEQ >quots [ [ N nkeep ] curry ] map concat [ N ndrop ] append >quotation ;

MACRO: ncleave ( seq n -- quot ) [ncleave] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Cleave into array
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [narr] ( seq n -- quot ) over length '[ _ _ ncleave _ narray ] ;

MACRO: narr ( seq n -- array ) [narr] ;

MACRO: 0arr ( seq -- array ) 0 [narr] ;
MACRO: 1arr ( seq -- array ) 1 [narr] ;
MACRO: 2arr ( seq -- array ) 2 [narr] ;
MACRO: 3arr ( seq -- array ) 3 [narr] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: <arr> ( seq -- )
  [ >quots ] [ length ] bi
 '[ _ cleave _ narray ] ;

MACRO: <2arr> ( seq -- )
  [ >quots ] [ length ] bi
 '[ _ 2cleave _ narray ] ;

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
 '[ _ spread _ narray ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: {bi*}  ( x y p q     -- {p(x),q(y)}      ) bi*  {2} ; inline
: {tri*} ( x y z p q r -- {p(x),q(y),r(z)} ) tri* {3} ; inline
