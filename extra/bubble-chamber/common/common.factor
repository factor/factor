
USING: kernel math accessors combinators.cleave vars ;

IN: bubble-chamber.common

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: collision-theta

: dim ( -- dim ) 1000 ;

: center ( -- point ) dim 2 / dup {2} ; foldable
