! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
IN: unix.getfsstat.freebsd

: MNT_WAIT        1       ; inline ! synchronously wait for I/O to complete
: MNT_NOWAIT      2       ; inline ! start all I/O, but do not wait for it 
: MNT_LAZY        3       ; inline ! push data not written by filesystem syncer 
: MNT_SUSPEND     4       ; inline ! Suspend file system after sync 

FUNCTION: int getfsstat ( statfs* buf, int bufsize, int flags ) ;
