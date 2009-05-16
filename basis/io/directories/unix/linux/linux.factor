! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.directories.unix kernel system unix ;
IN: io.directories.unix.linux

M: unix find-next-file ( DIR* -- byte-array )
    "dirent" <c-object>
    f <void*>
    [ readdir64_r 0 = [ (io-error) ] unless ] 2keep
    *void* [ drop f ] unless ;
