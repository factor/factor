! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data io.directories.unix kernel libc
math system unix classes.struct unix.ffi ;
IN: io.directories.unix.linux

: next-dirent ( DIR* dirent* -- dirent* ? )
    f void* <ref> [
        readdir64_r [ dup strerror libc-error ] unless-zero
    ] 2keep void* deref ; inline

M: linux (directory-entries) ( path -- seq )
    [
        dirent <struct>
        '[ _ _ next-dirent ] [ >directory-entry ] produce nip
    ] with-unix-directory ;
