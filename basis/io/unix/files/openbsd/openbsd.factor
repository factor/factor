! Copyright (C) 2005, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: unix system ;
IN: io.unix.files

M: openbsd find-next-file ( DIR* -- byte-array )
    readdir ;
