! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types classes.struct unix.types ;
IN: unix.time

! Big-endian glibc time64 places its 32-bit nanoseconds after a pad word.
STRUCT: timespec
    { sec time_t }
    { __pad int }
    { nsec long } ;
