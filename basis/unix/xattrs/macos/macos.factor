! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays continuations kernel libc literals retries
sequences strings unix.ffi ;
IN: unix.xattrs.macos

: list-xattrs-impl ( path size flags -- string )
    [ [ <byte-array> ] [ ] bi ] dip
    [ listxattr dup io-error ] 3keep 2drop swap head >string ;

: list-xattrs ( path flags -- out )
    '[ _ _ swapd list-xattrs-impl ]
    <immediate> ${ 512 16384 XATTR_MAXSIZE } retries ;
