! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel io.files unix.stat math unix
combinators system io.backend accessors alien.c-types
io.encodings.utf8 alien.strings ;
IN: unix.statfs.netbsd

TUPLE: netbsd-file-system-info < file-system-info
flag bsize frsize io-size
blocks blocks-free blocks-available blocks-reserved
files ffree
sync-reads sync-writes async-reads async-writes
fsidx fsid namemax owner spare fstype mnotonname mntfromname
file-system-type-name mount-from ;

: statvfs>file-system-info ( byte-array -- netbsd-file-system-info )
    [ \ netbsd-file-system-info new ] dip
    {
        [
            [ statvfs-f_bsize ]
            [ statvfs-f_bavail ] bi * >>free-space
        ]
        [ statvfs-f_flag >>flag ]
        [ statvfs-f_bsize >>bsize ]
        [ statvfs-f_frsize >>frsize ]
        [ statvfs-f_iosize >>io-size ]
        [ statvfs-f_blocks >>blocks ]
        [ statvfs-f_bfree >>blocks-free ]
        [ statvfs-f_favail >>flag ]
        [ statvfs-f_fresvd >>flag ]
        [ statvfs-f_files >>files ]
        [ statvfs-f_ffree >>ffree ]
        [ statvfs-f_syncreads >>sync-reads ]
        [ statvfs-f_syncwrites >>sync-writes ]
        [ statvfs-f_asyncreads >>async-writes ]
        [ statvfs-f_asyncwrites >>async-writes ]
        [ statvfs-f_fsidx >>fsidx ]
        [ statvfs-f_namemax >>namemax ]
        [ statvfs-f_owner >>owner ]
        [ statvfs-f_spare >>spare ]
        [ statvfs-f_fstypename utf8 alien>string >>file-system-type-name ]
        [ statvfs-f_mntonname utf8 alien>string >>mount-on ]
        [ statvfs-f_mntfromname utf8 alien>string >>mount-from ]
    } cleave ;

M: netbsd file-system-info
    normalize-path "statvfs" <c-object> tuck statvfs io-error 
    statvfs>file-system-info ;
