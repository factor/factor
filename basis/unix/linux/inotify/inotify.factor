! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax math math.bitwise classes.struct ;
IN: unix.linux.inotify

STRUCT: inotify-event
    { wd int }
    { mask uint }
    { cookie uint }
    { len uint }
    { name char[0] } ;

CONSTANT: IN_ACCESS HEX: 1         ! File was accessed
CONSTANT: IN_MODIFY HEX: 2         ! File was modified
CONSTANT: IN_ATTRIB HEX: 4         ! Metadata changed
CONSTANT: IN_CLOSE_WRITE HEX: 8    ! Writtable file was closed
CONSTANT: IN_CLOSE_NOWRITE HEX: 10 ! Unwrittable file closed
CONSTANT: IN_OPEN HEX: 20          ! File was opened
CONSTANT: IN_MOVED_FROM HEX: 40    ! File was moved from X
CONSTANT: IN_MOVED_TO HEX: 80      ! File was moved to Y
CONSTANT: IN_CREATE HEX: 100       ! Subfile was created
CONSTANT: IN_DELETE HEX: 200       ! Subfile was deleted
CONSTANT: IN_DELETE_SELF HEX: 400  ! Self was deleted
CONSTANT: IN_MOVE_SELF HEX: 800    ! Self was moved

CONSTANT: IN_UNMOUNT HEX: 2000     ! Backing fs was unmounted
CONSTANT: IN_Q_OVERFLOW HEX: 4000  ! Event queued overflowed
CONSTANT: IN_IGNORED HEX: 8000     ! File was ignored

: IN_CLOSE ( -- n ) { IN_CLOSE_WRITE IN_CLOSE_NOWRITE } flags ; foldable ! close
: IN_MOVE ( -- n ) { IN_MOVED_FROM IN_MOVED_TO } flags        ; foldable ! moves

CONSTANT: IN_ONLYDIR HEX: 1000000     ! only watch the path if it is a directory
CONSTANT: IN_DONT_FOLLOW HEX: 2000000 ! don't follow a sym link
CONSTANT: IN_MASK_ADD HEX: 20000000   ! add to the mask of an already existing watch
CONSTANT: IN_ISDIR HEX: 40000000      ! event occurred against dir
CONSTANT: IN_ONESHOT HEX: 80000000    ! only send event once

: IN_CHANGE_EVENTS ( -- n )
    {
        IN_MODIFY IN_ATTRIB IN_MOVED_FROM
        IN_MOVED_TO IN_DELETE IN_CREATE IN_DELETE_SELF
        IN_MOVE_SELF
    } flags ; foldable

: IN_ALL_EVENTS ( -- n )
    {
        IN_ACCESS IN_MODIFY IN_ATTRIB IN_CLOSE_WRITE
        IN_CLOSE_NOWRITE IN_OPEN IN_MOVED_FROM
        IN_MOVED_TO IN_DELETE IN_CREATE IN_DELETE_SELF
        IN_MOVE_SELF
    } flags ; foldable

FUNCTION: int inotify_init ( ) ;
FUNCTION: int inotify_add_watch ( int fd, char* name, uint mask  ) ;
FUNCTION: int inotify_rm_watch ( int fd, uint wd ) ;
