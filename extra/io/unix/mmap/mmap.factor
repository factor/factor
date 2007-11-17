! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien io io.files kernel math system unix io.unix.backend
io.mmap ;
IN: io.unix.mmap

: open-r/w ( path -- fd ) O_RDWR file-mode open dup io-error ;

: mmap-open ( length prot flags path -- alien fd )
    >r f -roll r> open-r/w [ 0 mmap ] keep
    over MAP_FAILED = [ close (io-error) ] when ;

M: unix-io <mapped-file> ( path length -- obj )
    swap >r
    dup PROT_READ PROT_WRITE bitor MAP_FILE MAP_SHARED bitor
    r> mmap-open \ mapped-file construct-boa ;

M: unix-io (close-mapped-file) ( mmap -- )
    [ mapped-file-address ] keep
    [ mapped-file-length munmap ] keep
    mapped-file-handle close
    io-error ;
