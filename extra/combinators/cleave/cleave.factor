
USING: kernel sequences macros combinators ;

IN: combinators.cleave

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
