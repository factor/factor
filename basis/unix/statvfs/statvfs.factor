! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators system vocabs ;
IN: unix.statvfs

os {
    { linux   [ "unix.statvfs.linux"   require ] }
    { macosx  [ "unix.statvfs.macosx"  require ] }
} case
