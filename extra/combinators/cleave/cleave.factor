
USING: kernel sequences macros ;

IN: combinators.cleave

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The cleaver family
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bi  ( x p q   -- p(x) q(x)      ) >r keep r> call          ; inline
: tri ( x p q r -- p(x) q(x) r(x) ) >r pick >r bi r> r> call ; inline

: tetra ( obj quot quot quot quot -- val val val val )
  >r >r pick >r bi r> r> r> bi ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 2bi ( x y p q -- p(x,y) q(x,y) ) >r 2keep r> call ; inline

: 2tri ( x y z p q r -- p(x,y,z) q(x,y,z) r(x,y,z) )
  >r >r 2keep r> 2keep r> call ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! General cleave

MACRO: cleave ( seq -- )
  dup
    [ drop [ dup ] ] map concat
  swap
  dup
    [ drop [ >r ] ]  map concat
  swap
    [ [ r> ] append ] map concat
  3append
    [ drop ]
  append ;

MACRO: 2cleave ( seq -- )
  dup
    [ drop [ 2dup ] ] map concat
  swap
  dup
    [ drop [ >r >r ] ] map concat
  swap
    [ [ r> r> ] append ] map concat
  3append
    [ 2drop ]
  append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The spread family
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bi* ( x y p q -- p(x) q(y) ) >r swap slip r> call ; inline

: 2bi* ( w x y z p q -- p(x) q(y) ) >r -rot 2slip r> call ; inline

: tri* ( x y z p q r -- p(x) q(y) r(z) )
  >r rot >r bi* r> r> call ; inline

: tetra* ( obj obj obj obj quot quot quot quot -- val val val val )
  >r roll >r tri* r> r> call ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! General spread

MACRO: spread ( seq -- )
  dup
    [ drop [ >r ] ]        map concat
  swap
    [ [ r> ] prepend ] map concat
  append ;

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
! Spread into array
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: <arr*> ( seq -- )
  [ >quots ] [ length ] bi
 '[ , spread , narray ] ;
