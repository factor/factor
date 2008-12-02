! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences system vocabs.loader combinators accessors
kernel math.order sorting ;
IN: unix.statfs

os {
    { linux   [ "unix.statfs.linux"   require ] }
    { macosx  [ "unix.statfs.macosx"  require ] }
    { freebsd [ "unix.statfs.freebsd" require ] }
    { netbsd  [ ] }
    { openbsd [ ] }
} case
