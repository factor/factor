! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types ;
IN: unix.types

! OpenRISC glibc uses 64-bit file offsets and time even with 32-bit cells.
TYPEDEF: ulonglong ino_t
TYPEDEF: ino_t __ino_t
TYPEDEF: longlong off_t
TYPEDEF: off_t __off_t
TYPEDEF: longlong blkcnt_t
TYPEDEF: longlong time_t
TYPEDEF: time_t __time_t
TYPEDEF: longlong suseconds_t
