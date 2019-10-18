! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien errors generic io io-internals kernel math
unix-io ;
USE: unix-internals ! shadow stream-close
IN: mmap

: PROT_NONE   0 ; inline
: PROT_READ   1 ; inline
: PROT_WRITE  2 ; inline
: PROT_EXEC   4 ; inline

: MAP_FILE    0 ; inline
: MAP_SHARED  1 ; inline
: MAP_PRIVATE 2 ; inline

: MAP_FAILED -1 <alien> ; inline

FUNCTION: void* mmap (  void* addr,
                        size_t len,
                        int prot,
                        int flags,
                        int fd,
                        off_t offset ) ;

FUNCTION: int munmap ( void* addr, size_t len ) ;

: mmap-open ( path prot flags -- alien fd )
    >r >r >r f r> [ file-length ] keep r> r> rot open-r/w 0
    over >r mmap dup MAP_FAILED = [ (io-error) ] when r> ;

TUPLE: mmap path address fd length ;

: make-mmap ( path prot flags -- obj )
    >r dupd r>
    pick >r mmap-open r> file-length <mmap> ;

! C: mmap-reader ( path -- obj )
    ! >r PROT_READ MAP_FILE MAP_SHARED bitor make-mmap r>
    ! [ set-delegate ] keep ;

! C: mmap-writer ( path -- obj )
    ! >r PROT_WRITE MAP_FILE MAP_SHARED bitor make-mmap r>
    ! [ set-delegate ] keep ;

: mmap-r/w ( path -- obj )
    PROT_READ PROT_WRITE bitor
    MAP_FILE MAP_SHARED bitor make-mmap ;

: mmap-close ( mmap -- )
    [ mmap-address ] keep
    [ mmap-length munmap io-error ] keep
    mmap-fd close ;
