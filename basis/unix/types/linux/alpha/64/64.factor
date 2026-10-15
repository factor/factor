! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax ;
IN: unix.types

TYPEDEF: uint ino_t
TYPEDEF: ino_t __ino_t
TYPEDEF: uint nlink_t
TYPEDEF: uint blksize_t
TYPEDEF: uint blkcnt_t
TYPEDEF: ulonglong blkcnt64_t
TYPEDEF: longlong __fsblkcnt64_t
