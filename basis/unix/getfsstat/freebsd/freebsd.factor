! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax unix.statfs.freebsd ;
IN: unix.getfsstat.freebsd

CONSTANT: MNT_WAIT    1   ! synchronously wait for I/O to complete
CONSTANT: MNT_NOWAIT  2   ! start all I/O, but do not wait for it
CONSTANT: MNT_LAZY    3   ! push data not written by filesystem syncer
CONSTANT: MNT_SUSPEND 4   ! suspend file system after sync


FUNCTION:  int getfsstat ( statfs* buf, long bufsize, int flags ) 
FUNCTION:  int getmntinfo ( statfs **mntbufp, int flags ) 
