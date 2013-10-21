! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data io.directories.unix kernel libc
system unix classes.struct unix.ffi ;
IN: io.directories.unix.linux

M: linux find-next-file ( DIR* -- dirent )
    dirent <struct>
    f void* <ref>
    [ [ readdir64_r ] unix-system-call 0 = [ (io-error) ] unless ] 2keep
    void* deref [ drop f ] unless ;
