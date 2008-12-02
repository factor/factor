! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators system vocabs.loader ;
IN: unix.statvfs

os {
    { linux   [ "unix.statvfs.linux"   require ] }
    { macosx  [ "unix.statvfs.macosx"  require ] }
    { freebsd [ "unix.statvfs.freebsd" require ] }
    { netbsd  [ "unix.statvfs.netbsd"  require ] }
    { openbsd [ "unix.statvfs.openbsd" require ] }
} case
