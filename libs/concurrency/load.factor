! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
REQUIRES: libs/dlists libs/serialize libs/match ;

PROVIDE: libs/concurrency
{ +files+ { 
  "concurrency.factor" 
  "concurrency.facts"
} }
{ +tests+ { 
  "concurrency-tests.factor" 
} }
{ +help+ { "concurrency" "concurrency" } } ;
