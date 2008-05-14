! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien io io.files kernel math system unix io.unix.backend
io.mmap destructors ;
IN: io.unix.mmap

: open-r/w ( path -- fd ) O_RDWR file-mode open-file ;

: mmap-open ( length prot flags path -- alien fd )
    [
        >r f -roll r> open-r/w dup close-later
        [ 0 mmap dup MAP_FAILED = [ (io-error) ] when ] keep
    ] with-destructors ;

M: unix (mapped-file) ( path length -- obj )
    swap >r
    dup
    PROT_READ PROT_WRITE bitor
    MAP_FILE MAP_SHARED bitor
    r> mmap-open f mapped-file boa ;

M: unix close-mapped-file ( mmap -- )
    [ [ address>> ] [ length>> ] bi munmap io-error ]
    [ handle>> close-file ]
    bi ;
