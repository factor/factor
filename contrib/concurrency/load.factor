! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
REQUIRES: contrib/dlists contrib/serialize contrib/match ;

PROVIDE: contrib/concurrency
{ +files+ { 
  "concurrency.factor" 
  "concurrency.facts"
} }
{ +tests+ { 
  "concurrency-tests.factor" 
} } ;
