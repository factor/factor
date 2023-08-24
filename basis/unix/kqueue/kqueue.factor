! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax system sequences vocabs.loader words
accessors vocabs ;
IN: unix.kqueue

<< "unix.kqueue." os name>> append require >>

FUNCTION: int kqueue ( )

! actions
CONSTANT: EV_ADD     0x1 ! add event to kq (implies enable)
CONSTANT: EV_DELETE  0x2 ! delete event from kq
CONSTANT: EV_ENABLE  0x4 ! enable event
CONSTANT: EV_DISABLE 0x8 ! disable event (not reported)

! flags
CONSTANT: EV_ONESHOT 0x10 ! only report one occurrence
CONSTANT: EV_CLEAR   0x20 ! clear event state after reporting

CONSTANT: EV_SYSFLAGS 0xf000 ! reserved by system
CONSTANT: EV_FLAG0    0x1000 ! filter-specific flag
CONSTANT: EV_FLAG1    0x2000 ! filter-specific flag

! returned values
CONSTANT: EV_EOF          0x8000 ! EOF detected
CONSTANT: EV_ERROR        0x4000 ! error, data contains errno

ALIAS: EV_POLL EV_FLAG0
ALIAS: EV_OOBAND EV_FLAG1

CONSTANT: NOTE_LOWAT      0x00000001 ! low water mark

CONSTANT: NOTE_DELETE     0x00000001 ! vnode was removed
CONSTANT: NOTE_WRITE      0x00000002 ! data contents changed
CONSTANT: NOTE_EXTEND     0x00000004 ! size increased
CONSTANT: NOTE_ATTRIB     0x00000008 ! attributes changed
CONSTANT: NOTE_LINK       0x00000010 ! link count changed
CONSTANT: NOTE_RENAME     0x00000020 ! vnode was renamed
CONSTANT: NOTE_REVOKE     0x00000040 ! vnode access was revoked

CONSTANT: NOTE_EXIT       0x80000000 ! process exited
CONSTANT: NOTE_FORK       0x40000000 ! process forked
CONSTANT: NOTE_EXEC       0x20000000 ! process exec'd
CONSTANT: NOTE_PCTRLMASK  0xf0000000 ! mask for hint bits
CONSTANT: NOTE_PDATAMASK  0x000fffff ! mask for pid

CONSTANT: NOTE_SECONDS    0x00000001 ! data is seconds
CONSTANT: NOTE_USECONDS   0x00000002 ! data is microseconds
CONSTANT: NOTE_NSECONDS   0x00000004 ! data is nanoseconds
CONSTANT: NOTE_ABSOLUTE   0x00000008 ! absolute timeout

CONSTANT: NOTE_TRACK      0x00000001 ! follow across forks
CONSTANT: NOTE_TRACKERR   0x00000002 ! could not track child
CONSTANT: NOTE_CHILD      0x00000004 ! am a child process
