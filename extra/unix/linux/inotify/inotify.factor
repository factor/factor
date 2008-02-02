! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
IN: unix.linux.inotify

C-STRUCT: inotify-event
    { "int" "wd" }       ! watch descriptor
    { "uint" "mask" }    ! watch mask
    { "uint" "cookie" }  ! cookie to synchronize two events
    { "uint" "len" }     ! length (including nulls) of name
    { "char[1]" "name" } ! stub for possible name
    ;

: IN_ACCESS HEX: 1 ; inline         ! File was accessed
: IN_MODIFY HEX: 2 ; inline         ! File was modified
: IN_ATTRIB HEX: 4 ; inline         ! Metadata changed
: IN_CLOSE_WRITE HEX: 8 ; inline    ! Writtable file was closed
: IN_CLOSE_NOWRITE HEX: 10 ; inline ! Unwrittable file closed
: IN_OPEN HEX: 20 ; inline          ! File was opened
: IN_MOVED_FROM HEX: 40 ; inline    ! File was moved from X
: IN_MOVED_TO HEX: 80 ; inline      ! File was moved to Y
: IN_CREATE HEX: 100 ; inline       ! Subfile was created
: IN_DELETE HEX: 200 ; inline       ! Subfile was deleted
: IN_DELETE_SELF HEX: 400 ; inline  ! Self was deleted
: IN_MOVE_SELF HEX: 800 ; inline    ! Self was moved

: IN_UNMOUNT HEX: 2000 ; inline     ! Backing fs was unmounted
: IN_Q_OVERFLOW HEX: 4000 ; inline  ! Event queued overflowed
: IN_IGNORED HEX: 8000 ; inline     ! File was ignored

: IN_CLOSE IN_CLOSE_WRITE IN_CLOSE_NOWRITE bitor ; inline ! close
: IN_MOVE IN_MOVED_FROM IN_MOVED_TO bitor ; inline        ! moves

: IN_ONLYDIR HEX: 1000000 ; inline     ! only watch the path if it is a directory
: IN_DONT_FOLLOW HEX: 2000000 ; inline ! don't follow a sym link
: IN_MASK_ADD HEX: 20000000 ; inline   ! add to the mask of an already existing watch
: IN_ISDIR HEX: 40000000 ; inline      ! event occurred against dir
: IN_ONESHOT HEX: 80000000 ; inline    ! only send event once

: IN_ALL_EVENTS
    {
        IN_ACCESS IN_MODIFY IN_ATTRIB IN_CLOSE_WRITE
        IN_CLOSE_NOWRITE IN_OPEN IN_MOVED_FROM
        IN_MOVED_TO IN_DELETE IN_CREATE IN_DELETE_SELF
        IN_MOVE_SELF
    } flags ; foldable

FUNCTION: int inotify_init ( void ) ;
FUNCTION: int inotify_add_watch ( int fd, char* name, u32 mask  ) ;
FUNCTION: int inotify_rm_watch ( int fd, u32 wd ) ;
