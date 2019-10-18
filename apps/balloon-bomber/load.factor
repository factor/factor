! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
REQUIRES: apps/space-invaders libs/cpu-8080 libs/concurrency libs/openal ;

PROVIDE: apps/balloon-bomber
{ 
  +files+ {
    "balloon-bomber.factor"
    "balloon-bomber.facts"
  } 
} 
{
  +help+ {
    "balloon-bomber" "balloon-bomber" 
  }
} ;

USING: balloon-bomber ;

MAIN: apps/balloon-bomber run ;
