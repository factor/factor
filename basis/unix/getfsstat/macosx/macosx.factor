! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax unix.statfs.macosx ;
IN: unix.getfsstat.macosx

CONSTANT: MNT_WAIT    1   ! synchronously wait for I/O to complete
CONSTANT: MNT_NOWAIT  2   ! start all I/O, but do not wait for it

FUNCTION: int getfsstat64 ( statfs64* buf, int bufsize, int flags )
