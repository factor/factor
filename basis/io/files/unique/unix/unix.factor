! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.backend.unix io.files.unique.private literals system
unix unix.ffi ;
IN: io.files.unique.unix

CONSTANT: open-unique-flags flags{ O_RDWR O_CREAT O_EXCL }

M: unix (touch-unique-file)
    open-unique-flags file-mode open-file close-file ;
