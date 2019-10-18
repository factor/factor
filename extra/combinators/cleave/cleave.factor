
USING: kernel ;

IN: combinators.cleave

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The cleaver family
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bi ( obj quot quot -- val val ) >r over slip r> call ; inline

: tri ( obj quot quot quot -- val val val )
  >r pick >r bi r> r> call ; inline

: tetra ( obj quot quot quot quot -- val val val val )
  >r >r pick >r bi r> r> r> bi ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 2bi ( obj obj quot quot -- val val ) >r 2keep r> call ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The spread family
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bi* ( obj obj quot quot -- val val ) >r swap >r call r> r> call ; inline

: tri* ( obj obj obj quot quot quot -- val val val )
  >r rot >r bi* r> r> call ; inline

: tetra* ( obj obj obj obj quot quot quot quot -- val val val val )
  >r roll >r tri* r> r> call ; inline
