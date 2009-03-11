
USING: kernel combinators sequences macros fry newfx combinators.cleave ;

IN: combinators.conditional

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: 1if ( test then else -- ) '[ dup @ _ _ if ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: 1cond ( tbl -- )
  [ [ 1st [ dup ] prepend ] [ 2nd ] bi {2} ] map
  [ cond ] prefix-on ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

