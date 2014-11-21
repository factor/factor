! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays destructors environment io.backend.unix
io.files io.files.private io.pathnames io.ports kernel libc
literals system unix unix.ffi ;
IN: io.files.unix

M: unix cwd ( -- path )
    MAXPATHLEN [ <byte-array> ] keep
    [ getcwd ] unix-system-call
    [ throw-errno ] unless* ;

M: unix cd ( path -- ) [ chdir ] unix-system-call drop ;

CONSTANT: read-flags flags{ O_RDONLY }

: open-read ( path -- fd ) read-flags file-mode open-file ;

M: unix (file-reader) ( path -- stream )
    open-read <fd> init-fd <input-port> ;

CONSTANT: write-flags flags{ O_WRONLY O_CREAT O_TRUNC }

: open-write ( path -- fd )
    write-flags file-mode open-file ;

M: unix (file-writer) ( path -- stream )
    open-write <fd> init-fd <output-port> ;

CONSTANT: append-flags flags{ O_WRONLY O_APPEND O_CREAT }

: open-append ( path -- fd )
    [
        append-flags file-mode open-file |dispose
        dup 0 SEEK_END [ lseek ] unix-system-call drop
    ] with-destructors ;

M: unix (file-appender) ( path -- stream )
    open-append <fd> init-fd <output-port> ;

M: unix home "HOME" os-env ;
