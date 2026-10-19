! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.c-types ;
IN: unix.types

! glibc SPARC uses a 32-bit link count in both ELF32 and ELF64.
TYPEDEF: uint nlink_t
