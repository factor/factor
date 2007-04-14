! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax system sequences vocabs.loader ;
IN: unix.kqueue

<< "unix.kqueue." os append require >>

FUNCTION: int kqueue ( ) ;

: EVFILT_READ     -1 ; inline
: EVFILT_WRITE    -2 ; inline
: EVFILT_AIO      -3 ; inline ! attached to aio requests
: EVFILT_VNODE    -4 ; inline ! attached to vnodes
: EVFILT_PROC     -5 ; inline ! attached to struct proc
: EVFILT_SIGNAL   -6 ; inline ! attached to struct proc
: EVFILT_TIMER    -7 ; inline ! timers
: EVFILT_MACHPORT -8 ; inline ! Mach ports
: EVFILT_FS       -9 ; inline ! Filesystem events

! actions
: EV_ADD     HEX: 1 ; inline ! add event to kq (implies enable)
: EV_DELETE  HEX: 2 ; inline ! delete event from kq
: EV_ENABLE  HEX: 4 ; inline ! enable event
: EV_DISABLE HEX: 8 ; inline ! disable event (not reported)

! flags
: EV_ONESHOT HEX: 10 ; inline ! only report one occurrence
: EV_CLEAR   HEX: 20 ; inline ! clear event state after reporting

: EV_SYSFLAGS HEX: f000 ; inline ! reserved by system
: EV_FLAG0    HEX: 1000 ; inline ! filter-specific flag
: EV_FLAG1    HEX: 2000 ; inline ! filter-specific flag

! returned values
: EV_EOF          HEX: 8000 ; inline ! EOF detected
: EV_ERROR        HEX: 4000 ; inline ! error, data contains errno

: EV_POLL EV_FLAG0 ; inline
: EV_OOBAND EV_FLAG1 ; inline

: NOTE_LOWAT      HEX: 00000001 ; inline ! low water mark

: NOTE_DELETE     HEX: 00000001 ; inline ! vnode was removed
: NOTE_WRITE      HEX: 00000002 ; inline ! data contents changed
: NOTE_EXTEND     HEX: 00000004 ; inline ! size increased
: NOTE_ATTRIB     HEX: 00000008 ; inline ! attributes changed
: NOTE_LINK       HEX: 00000010 ; inline ! link count changed
: NOTE_RENAME     HEX: 00000020 ; inline ! vnode was renamed
: NOTE_REVOKE     HEX: 00000040 ; inline ! vnode access was revoked

: NOTE_EXIT       HEX: 80000000 ; inline ! process exited
: NOTE_FORK       HEX: 40000000 ; inline ! process forked
: NOTE_EXEC       HEX: 20000000 ; inline ! process exec'd
: NOTE_PCTRLMASK  HEX: f0000000 ; inline ! mask for hint bits
: NOTE_PDATAMASK  HEX: 000fffff ; inline ! mask for pid

: NOTE_SECONDS    HEX: 00000001 ; inline ! data is seconds
: NOTE_USECONDS   HEX: 00000002 ; inline ! data is microseconds
: NOTE_NSECONDS   HEX: 00000004 ; inline ! data is nanoseconds
: NOTE_ABSOLUTE   HEX: 00000008 ; inline ! absolute timeout

: NOTE_TRACK      HEX: 00000001 ; inline ! follow across forks
: NOTE_TRACKERR   HEX: 00000002 ; inline ! could not track child
: NOTE_CHILD      HEX: 00000004 ; inline ! am a child process
