! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.directories.unix kernel system unix
classes.struct unix.ffi ;
IN: io.directories.unix.linux

M: unix find-next-file ( DIR* -- dirent )
    dirent <struct>
    f <void*>
    [ [ readdir64_r ] unix-system-call 0 = [ (io-error) ] unless ] 2keep
    *void* [ drop f ] unless ;
