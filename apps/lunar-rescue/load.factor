! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
REQUIRES: apps/space-invaders libs/cpu-8080 libs/concurrency libs/openal ;

PROVIDE: apps/lunar-rescue
{ 
  +files+ {
    "lunar-rescue.factor"
    "lunar-rescue.facts"
  } 
} 
{
  +help+ {
    "lunar-rescue" "lunar-rescue" 
  }
} ;

USING: lunar-rescue ;

MAIN: apps/lunar-rescue run ;
