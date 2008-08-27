! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Balloon Bomber: http://www.mameworld.net/maws/romset/ballbomb
!
USING: kernel space-invaders cpu.8080 ui ;
IN: balloon-bomber

TUPLE: balloon-bomber ; 

: <balloon-bomber> ( -- cpu )
  <space-invaders> balloon-bomber construct-delegate ;

: run ( -- )  
  "Balloon Bomber" <balloon-bomber> {
    { HEX: 0000 "ballbomb/tn01" }
    { HEX: 0800 "ballbomb/tn02" }
    { HEX: 1000 "ballbomb/tn03" }
    { HEX: 1800 "ballbomb/tn04" }
    { HEX: 4000 "ballbomb/tn05-1" }
  } [ (run) ] with-ui ;

MAIN: run
