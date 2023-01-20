! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
!
! Balloon Bomber: https://www.emuparadise.me/M.A.M.E._-_Multiple_Arcade_Machine_Emulator_ROMs/Balloon_Bomber/11301
USING: kernel roms.space-invaders ui ;
IN: roms.balloon-bomber

TUPLE: balloon-bomber < space-invaders ;

: <balloon-bomber> ( -- cpu )
    balloon-bomber new cpu-init ;

CONSTANT: rom-info {
    { 0x0000 "ballbomb/tn01" }
    { 0x0800 "ballbomb/tn02" }
    { 0x1000 "ballbomb/tn03" }
    { 0x1800 "ballbomb/tn04" }
    { 0x4000 "ballbomb/tn05-1" }
}

: run-balloon ( -- )
    [
        "Balloon Bomber" <balloon-bomber> rom-info run-rom
    ] with-ui ;

MAIN: run-balloon
