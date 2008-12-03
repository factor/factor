! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
IN: unix.getfsstat.macosx

: MNT_WAIT    1   ; inline ! synchronously wait for I/O to complete
: MNT_NOWAIT  2   ; inline ! start all I/O, but do not wait for it

FUNCTION: int getfsstat64 ( statfs* buf, int bufsize, int flags ) ;
