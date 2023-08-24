! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays continuations destructors environment
io.backend.unix io.files io.files.private io.pathnames io.ports kernel
libc literals math system unix unix.ffi ;
IN: io.files.unix

: (cwd) ( bufsiz -- path )
    [
        dup <byte-array> over [ getcwd ] unix-system-call nip
    ] [
        dup errno>> ERANGE = [
            drop 2 * (cwd)
        ] [ rethrow ] if
    ] recover ;

M: unix cwd
    4096 (cwd) ;

M: unix cd [ chdir ] unix-system-call drop ;

CONSTANT: read-flags flags{ O_RDONLY }

: open-read ( path -- fd ) read-flags file-mode open-file ;

M: unix (file-reader)
    open-read <fd> init-fd <input-port> ;

CONSTANT: write-flags flags{ O_WRONLY O_CREAT O_TRUNC }

: open-write ( path -- fd )
    write-flags file-mode open-file ;

M: unix (file-writer)
    open-write <fd> init-fd <output-port> ;

CONSTANT: append-flags flags{ O_WRONLY O_APPEND O_CREAT }

: open-append ( path -- fd )
    [
        append-flags file-mode open-file |dispose
        dup 0 SEEK_END [ lseek ] unix-system-call drop
    ] with-destructors ;

M: unix (file-appender)
    open-append <fd> init-fd <output-port> ;

M: unix home "HOME" os-env ;
