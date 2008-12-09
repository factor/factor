! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.ports io.unix.backend math.bitwise
unix system io.files.unique ;
IN: io.unix.files.unique

: open-unique-flags ( -- flags )
    { O_RDWR O_CREAT O_EXCL } flags ;

M: unix touch-unique-file ( path -- )
    open-unique-flags file-mode open-file close-file ;

M: unix temporary-path ( -- path ) "/tmp" ;
