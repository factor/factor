! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien io io.files kernel math math.bitwise system unix
io.backend.unix io.ports io.mmap destructors locals accessors ;
IN: io.mmap.unix

:: mmap-open ( path length prot flags open-mode -- alien fd )
    [
        f length prot flags
        path open-mode file-mode open-file [ <fd> |dispose drop ] keep
        [ 0 mmap dup MAP_FAILED = [ (io-error) ] when ] keep
    ] with-destructors ;

M: unix (mapped-file-r/w)
    { PROT_READ PROT_WRITE } flags
    { MAP_FILE MAP_SHARED } flags
    O_RDWR mmap-open ;

M: unix (mapped-file-reader)
    { PROT_READ } flags
    { MAP_FILE MAP_SHARED } flags
    O_RDONLY mmap-open ;

M: unix close-mapped-file ( mmap -- )
    [ [ address>> ] [ length>> ] bi munmap io-error ]
    [ handle>> close-file ] bi ;
