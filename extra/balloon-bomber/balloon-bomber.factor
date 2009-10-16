! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Balloon Bomber: http://www.mameworld.net/maws/romset/ballbomb
!
USING: 
    cpu.8080
    kernel 
    space-invaders
    ui 
;
IN: balloon-bomber

TUPLE: balloon-bomber < space-invaders ; 

: <balloon-bomber> ( -- cpu )
  balloon-bomber new cpu-init ;

CONSTANT: rom-info {
    { HEX: 0000 "ballbomb/tn01" }
    { HEX: 0800 "ballbomb/tn02" }
    { HEX: 1000 "ballbomb/tn03" }
    { HEX: 1800 "ballbomb/tn04" }
    { HEX: 4000 "ballbomb/tn05-1" }
  }

: run-balloon ( -- )  
  [ "Balloon Bomber" <balloon-bomber>  rom-info (run) ] with-ui ;

MAIN: run-balloon
