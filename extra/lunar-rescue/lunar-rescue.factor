! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Lunar Rescue: http://www.mameworld.net/maws/romset/lrescue
!
USING: accessors cpu.8080 cpu.8080.emulator kernel
space-invaders ui ;
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
        <lunar-rescue>
        rom-info over load-rom*
        <invaders-gadget> t >>windowed?
        "Lunar Rescue" open-window
    ] with-ui ;

MAIN: run-lunar
