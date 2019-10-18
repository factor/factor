! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
REQUIRES: libs/shuffle libs/cpu-8080 libs/concurrency libs/openal ;

PROVIDE: apps/space-invaders
{ 
  +files+ {
    "space-invaders.factor"
    "space-invaders.facts"
  } 
} 
{
  +help+ {
    "space-invaders" "space-invaders"
  }
} ;

USING: space-invaders ;

MAIN: apps/space-invaders run ;
