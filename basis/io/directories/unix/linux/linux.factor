! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data classes.struct fry
io.directories io.directories.unix kernel libc math sequences
system unix.ffi ;
IN: io.directories.unix.linux

: next-dirent ( DIR* dirent* -- dirent* ? )
    f void* <ref> [
        readdir64_r [ (throw-errno) ] unless-zero
    ] 2keep void* deref ; inline

M: linux (directory-entries)
    [
        dirent new
        '[ _ _ next-dirent ] [ >directory-entry ] produce nip
    ] with-unix-directory ;
