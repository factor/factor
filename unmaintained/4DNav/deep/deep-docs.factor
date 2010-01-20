! Copyright (C) 2008 Jean-François Bigot.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations sequences ;
IN: 4DNav.deep

! HELP: deep-cleave-quots
! { $values
!     { "seq" sequence }
!     { "quot" quotation }
! }
! { $description "A word to build a soquence from a sequence of quotation" }
! 
! { $examples
! "It is useful to build matrix"
! { $example "USING: math math.trig ; "
!     " 30 deg>rad "
!    "  {  { [ cos ] [ sin neg ]   0 } "
!    "     { [ sin ] [ cos ]       0 } "
!    "     {   0       0           1 } "
!    "  } deep-cleave-quots " 
!     " "
! 
! 
! } }
! ;

ARTICLE: "4DNav.deep" "Deep"
{ $vocab-link "4DNav.deep" }
;

ABOUT: "4DNav.deep"
