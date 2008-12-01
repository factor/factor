! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel unix.stat math unix
combinators system io.backend accessors alien.c-types
io.encodings.utf8 alien.strings unix.types unix.statfs io.files ;
IN: io.unix.files.netbsd

TUPLE: netbsd-file-system-info < unix-file-system-info
owner io-size blocks-reserved
sync-reads sync-writes async-reads async-writes
fsidx fstype mnotonname mntfromname mount-from spare ;

M: netbsd file-system-statvfs
    "statvfs" <c-object> tuck statvfs io-error ;
