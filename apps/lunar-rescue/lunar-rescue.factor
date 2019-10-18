! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Lunar Rescue: http://www.mameworld.net/maws/romset/lrescue
!
IN: lunar-rescue
USING: kernel space-invaders cpu-8080 sequences generic openal io gadgets ;

TUPLE: lunar-rescue ; 

C: lunar-rescue ( -- cpu )
  [ <space-invaders> swap set-delegate ] keep ;

: run ( -- )  
  "Lunar Rescue" <lunar-rescue> {
    { HEX: 0000 "lrescue/lrescue.1" }
    { HEX: 0800 "lrescue/lrescue.2" }
    { HEX: 1000 "lrescue/lrescue.3" }
    { HEX: 1800 "lrescue/lrescue.4" }
    { HEX: 4000 "lrescue/lrescue.5" }
    { HEX: 4800 "lrescue/lrescue.6" }
  } (run) ;
