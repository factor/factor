! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Lunar Rescue: http://www.mamedb.com/game/lrescue
!
USING: kernel space-invaders ui ;
IN: lunar-rescue

TUPLE: lunar-rescue < space-invaders ;

: <lunar-rescue> ( -- cpu )
    lunar-rescue new cpu-init ;

CONSTANT: rom-info {
    { 0x0000 "lrescue/lrescue.1" }
    { 0x0800 "lrescue/lrescue.2" }
    { 0x1000 "lrescue/lrescue.3" }
    { 0x1800 "lrescue/lrescue.4" }
    { 0x4000 "lrescue/lrescue.5" }
    { 0x4800 "lrescue/lrescue.6" }
}

: run-lunar ( -- )
    [
        "Lunar Rescue" <lunar-rescue> rom-info run-rom
    ] with-ui ;

MAIN: run-lunar
