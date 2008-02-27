
USING: kernel sequences macros ;

IN: combinators.cleave

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The cleaver family
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bi ( obj quot quot -- val val ) >r keep r> call ; inline

: tri ( obj quot quot quot -- val val val )
  >r pick >r bi r> r> call ; inline

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

: bi* ( obj obj quot quot -- val val ) >r swap slip r> call ; inline

: tri* ( obj obj obj quot quot quot -- val val val )
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
