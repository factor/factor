! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax math math.bitwise classes.struct
literals ;
IN: unix.linux.inotify

STRUCT: inotify-event
    { wd int }
    { mask uint }
    { cookie uint }
    { len uint }
    { name char[0] } ;

CONSTANT: IN_ACCESS 0x1         ! File was accessed
CONSTANT: IN_MODIFY 0x2         ! File was modified
CONSTANT: IN_ATTRIB 0x4         ! Metadata changed
CONSTANT: IN_CLOSE_WRITE 0x8    ! Writtable file was closed
CONSTANT: IN_CLOSE_NOWRITE 0x10 ! Unwrittable file closed
CONSTANT: IN_OPEN 0x20          ! File was opened
CONSTANT: IN_MOVED_FROM 0x40    ! File was moved from X
CONSTANT: IN_MOVED_TO 0x80      ! File was moved to Y
CONSTANT: IN_CREATE 0x100       ! Subfile was created
CONSTANT: IN_DELETE 0x200       ! Subfile was deleted
CONSTANT: IN_DELETE_SELF 0x400  ! Self was deleted
CONSTANT: IN_MOVE_SELF 0x800    ! Self was moved

CONSTANT: IN_UNMOUNT 0x2000     ! Backing fs was unmounted
CONSTANT: IN_Q_OVERFLOW 0x4000  ! Event queued overflowed
CONSTANT: IN_IGNORED 0x8000     ! File was ignored

CONSTANT: IN_CLOSE flags{ IN_CLOSE_WRITE IN_CLOSE_NOWRITE }
CONSTANT: IN_MOVE flags{ IN_MOVED_FROM IN_MOVED_TO }

CONSTANT: IN_ONLYDIR 0x1000000     ! only watch the path if it is a directory
CONSTANT: IN_DONT_FOLLOW 0x2000000 ! don't follow a sym link
CONSTANT: IN_MASK_ADD 0x20000000   ! add to the mask of an already existing watch
CONSTANT: IN_ISDIR 0x40000000      ! event occurred against dir
CONSTANT: IN_ONESHOT 0x80000000    ! only send event once

CONSTANT: IN_CHANGE_EVENTS
    flags{
        IN_MODIFY IN_ATTRIB IN_MOVED_FROM
        IN_MOVED_TO IN_DELETE IN_CREATE IN_DELETE_SELF
        IN_MOVE_SELF
    }

CONSTANT: IN_ALL_EVENTS
    flags{
        IN_ACCESS IN_MODIFY IN_ATTRIB IN_CLOSE_WRITE
        IN_CLOSE_NOWRITE IN_OPEN IN_MOVED_FROM
        IN_MOVED_TO IN_DELETE IN_CREATE IN_DELETE_SELF
        IN_MOVE_SELF
    }

FUNCTION: int inotify_init ( )
FUNCTION: int inotify_add_watch ( int fd, c-string name, uint mask )
FUNCTION: int inotify_rm_watch ( int fd, uint wd )
