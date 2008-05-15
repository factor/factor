! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien io io.files kernel math math.bitfields system unix
io.unix.backend io.ports io.mmap destructors locals accessors ;
IN: io.unix.mmap

: open-r/w ( path -- fd ) O_RDWR file-mode open-file ;

:: mmap-open ( length prot flags path -- alien fd )
    [
        f length prot flags
        path open-r/w |close-handle
        [ 0 mmap dup MAP_FAILED = [ (io-error) ] when ] keep
    ] with-destructors ;

M: unix (mapped-file)
    swap >r
    { PROT_READ PROT_WRITE } flags
    { MAP_FILE MAP_SHARED } flags
    r> mmap-open ;

M: unix close-mapped-file ( mmap -- )
    [ [ address>> ] [ length>> ] bi munmap io-error ]
    [ handle>> close-file ]
    bi ;
