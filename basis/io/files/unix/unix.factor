! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: unix byte-arrays kernel io.backend.unix math.bitwise
io.ports io.files io.files.private io.pathnames environment
destructors system ;
IN: io.files.unix

M: unix cwd ( -- path )
    MAXPATHLEN [ <byte-array> ] keep getcwd
    [ (io-error) ] unless* ;

M: unix cd ( path -- ) [ chdir ] unix-system-call drop ;

: read-flags ( -- n ) O_RDONLY ; inline

: open-read ( path -- fd ) O_RDONLY file-mode open-file ;

M: unix (file-reader) ( path -- stream )
    open-read <fd> init-fd <input-port> ;

: write-flags ( -- n )
    { O_WRONLY O_CREAT O_TRUNC } flags ; inline

: open-write ( path -- fd )
    write-flags file-mode open-file ;

M: unix (file-writer) ( path -- stream )
    open-write <fd> init-fd <output-port> ;

: append-flags ( -- n )
    { O_WRONLY O_APPEND O_CREAT } flags ; inline

: open-append ( path -- fd )
    [
        append-flags file-mode open-file |dispose
        dup 0 SEEK_END lseek io-error
    ] with-destructors ;

M: unix (file-appender) ( path -- stream )
    open-append <fd> init-fd <output-port> ;

M: unix home "HOME" os-env ;
