! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
REQUIRES: libs/furnace libs/sqlite libs/basic-authentication ;

PROVIDE: apps/article-manager
{ 
  +files+ { 
  "article-manager-db.factor"
  "article-manager.factor"
  "article-manager.facts"
  } 
} {
  +tests+ { 
  }
}  
{ +help+ { "article-manager" "article-manager" } } 
 ;
