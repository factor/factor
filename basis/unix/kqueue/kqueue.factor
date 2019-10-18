! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax system sequences vocabs.loader words
accessors ;
IN: unix.kqueue

<< "unix.kqueue." os name>> append require >>

FUNCTION: int kqueue ( ) ;

! actions
CONSTANT: EV_ADD     HEX: 1 ! add event to kq (implies enable)
CONSTANT: EV_DELETE  HEX: 2 ! delete event from kq
CONSTANT: EV_ENABLE  HEX: 4 ! enable event
CONSTANT: EV_DISABLE HEX: 8 ! disable event (not reported)

! flags
CONSTANT: EV_ONESHOT HEX: 10 ! only report one occurrence
CONSTANT: EV_CLEAR   HEX: 20 ! clear event state after reporting

CONSTANT: EV_SYSFLAGS HEX: f000 ! reserved by system
CONSTANT: EV_FLAG0    HEX: 1000 ! filter-specific flag
CONSTANT: EV_FLAG1    HEX: 2000 ! filter-specific flag

! returned values
CONSTANT: EV_EOF          HEX: 8000 ! EOF detected
CONSTANT: EV_ERROR        HEX: 4000 ! error, data contains errno

ALIAS: EV_POLL EV_FLAG0
ALIAS: EV_OOBAND EV_FLAG1

CONSTANT: NOTE_LOWAT      HEX: 00000001 ! low water mark

CONSTANT: NOTE_DELETE     HEX: 00000001 ! vnode was removed
CONSTANT: NOTE_WRITE      HEX: 00000002 ! data contents changed
CONSTANT: NOTE_EXTEND     HEX: 00000004 ! size increased
CONSTANT: NOTE_ATTRIB     HEX: 00000008 ! attributes changed
CONSTANT: NOTE_LINK       HEX: 00000010 ! link count changed
CONSTANT: NOTE_RENAME     HEX: 00000020 ! vnode was renamed
CONSTANT: NOTE_REVOKE     HEX: 00000040 ! vnode access was revoked

CONSTANT: NOTE_EXIT       HEX: 80000000 ! process exited
CONSTANT: NOTE_FORK       HEX: 40000000 ! process forked
CONSTANT: NOTE_EXEC       HEX: 20000000 ! process exec'd
CONSTANT: NOTE_PCTRLMASK  HEX: f0000000 ! mask for hint bits
CONSTANT: NOTE_PDATAMASK  HEX: 000fffff ! mask for pid

CONSTANT: NOTE_SECONDS    HEX: 00000001 ! data is seconds
CONSTANT: NOTE_USECONDS   HEX: 00000002 ! data is microseconds
CONSTANT: NOTE_NSECONDS   HEX: 00000004 ! data is nanoseconds
CONSTANT: NOTE_ABSOLUTE   HEX: 00000008 ! absolute timeout

CONSTANT: NOTE_TRACK      HEX: 00000001 ! follow across forks
CONSTANT: NOTE_TRACKERR   HEX: 00000002 ! could not track child
CONSTANT: NOTE_CHILD      HEX: 00000004 ! am a child process
