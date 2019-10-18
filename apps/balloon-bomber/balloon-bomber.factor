! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Balloon Bomber: http://www.mameworld.net/maws/romset/ballbomb
!
IN: balloon-bomber
USING: kernel space-invaders cpu-8080 sequences generic openal io gadgets ;

TUPLE: balloon-bomber ; 

C: balloon-bomber ( -- cpu )
  [ <space-invaders> swap set-delegate ] keep ;

: run ( -- )  
  "Balloon Bomber" <balloon-bomber> {
    { HEX: 0000 "ballbomb/tn01" }
    { HEX: 0800 "ballbomb/tn02" }
    { HEX: 1000 "ballbomb/tn03" }
    { HEX: 1800 "ballbomb/tn04" }
    { HEX: 4000 "ballbomb/tn05-1" }
  } (run) ;
