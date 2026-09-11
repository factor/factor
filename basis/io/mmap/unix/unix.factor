! Copyright (C) 2007 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations destructors io.backend.unix io.mmap
io.mmap.private kernel libc literals locals system unix unix.ffi ;
IN: io.mmap.unix

:: mmap-open ( path length prot flags open-mode -- alien fd )
    [
        path open-mode file-mode open-file <fd> init-fd |dispose :> fd
        f length prot flags fd handle-fd 0 mmap
        dup MAP_FAILED = [ throw-errno ] when
        fd
    ] with-destructors ;

M: unix (mapped-file-r/w)
    flags{ PROT_READ PROT_WRITE }
    flags{ MAP_FILE MAP_SHARED }
    O_RDWR mmap-open ;

M: unix (mapped-file-reader)
    flags{ PROT_READ }
    flags{ MAP_FILE MAP_SHARED }
    O_RDONLY mmap-open ;

M: unix close-mapped-file
    [ dup [ address>> ] [ length>> ] bi munmap io-error ]
    [ handle>> dispose ] finally ;
