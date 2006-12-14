! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
REQUIRES: libs/http-client apps/rss ;

PROVIDE: libs/google-search 
{ 
  +files+ { 
  "google-search.factor" 
  "google-search.facts"
  } 
} {
  +tests+ { 
  }
} { 
  +help+ { "google-search" "overview" } 
} ;
