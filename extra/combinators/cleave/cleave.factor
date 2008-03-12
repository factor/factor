
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

: 2bi ( obj obj quot quot -- val val ) >r 2keep r> call ; inline

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The spread family
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bi* ( x y p q -- p(x) q(y) ) >r swap slip r> call ; inline

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
    [ [ r> ] swap append ] map concat
  append ;
