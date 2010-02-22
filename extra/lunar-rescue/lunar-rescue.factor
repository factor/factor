! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Lunar Rescue: http://www.mameworld.net/maws/romset/lrescue
!
USING: 
    cpu.8080
    kernel 
    space-invaders
    ui 
;
IN: lunar-rescue

TUPLE: lunar-rescue < space-invaders ; 

: <lunar-rescue> ( -- cpu )
  lunar-rescue new cpu-init ;

CONSTANT: rom-info {
    { HEX: 0000 "lrescue/lrescue.1" }
    { HEX: 0800 "lrescue/lrescue.2" }
    { HEX: 1000 "lrescue/lrescue.3" }
    { HEX: 1800 "lrescue/lrescue.4" }
    { HEX: 4000 "lrescue/lrescue.5" }
    { HEX: 4800 "lrescue/lrescue.6" }
  }

: run-lunar ( -- )  
  [ "Lunar Rescue" <lunar-rescue>  rom-info (run) ] with-ui ;

MAIN: run-lunar
