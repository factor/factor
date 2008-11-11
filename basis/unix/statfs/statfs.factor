! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences system vocabs.loader combinators accessors
kernel math.order sorting ;
IN: unix.statfs

HOOK: >file-system-info os ( struct -- statfs )

HOOK: file-systems os ( -- array )

os {
    { linux   [ "unix.statfs.linux"   require ] }
    { macosx  [ "unix.statfs.macosx"  require ] }
    { freebsd [ "unix.statfs.freebsd" require ] }
    { netbsd  [ "unix.statfs.netbsd"  require ] }
    { openbsd [ "unix.statfs.openbsd" require ] }
} case
