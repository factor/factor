! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.ports io.backend.unix math.bitwise
unix system io.files.unique unix.ffi literals ;
IN: io.files.unique.unix

CONSTANT: open-unique-flags flags{ O_RDWR O_CREAT O_EXCL }

M: unix (touch-unique-file) ( path -- )
    open-unique-flags file-mode open-file close-file ;

M: unix default-temporary-directory ( -- path ) "/tmp" ;
