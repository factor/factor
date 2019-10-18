! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.struct combinators
combinators.short-circuit continuations csv fry io.backend
io.encodings.utf8 io.files.info io.files.info.unix io.pathnames kernel
libc math math.parser sequences splitting strings system
unix.statfs.linux unix.statvfs.linux ;
FROM: csv => delimiter ;
IN: io.files.info.unix.linux

TUPLE: linux-file-system-info < unix-file-system-info
namelen ;

M: linux new-file-system-info linux-file-system-info new ;

M: linux file-system-statfs ( path -- statfs )
    \ statfs64 <struct> [ statfs64 io-error ] keep ;

M: linux statfs>file-system-info ( file-system-info statfs -- file-system-info' )
    {
        [ f_type>> >>type ]
        [ f_bsize>> >>block-size ]
        [ f_blocks>> >>blocks ]
        [ f_bfree>> >>blocks-free ]
        [ f_bavail>> >>blocks-available ]
        [ f_files>> >>files ]
        [ f_ffree>> >>files-free ]
        [ f_fsid>> >>id ]
        [ f_namelen>> >>namelen ]
        [ f_frsize>> >>preferred-block-size ]
        ! [ statfs64-f_spare >>spare ]
    } cleave ;

M: linux file-system-statvfs ( path -- statvfs )
    \ statvfs64 <struct> [ statvfs64 io-error ] keep ;

M: linux statvfs>file-system-info ( file-system-info statfs -- file-system-info' )
    {
        [ f_flag>> >>flags ]
        [ f_namemax>> >>name-max ]
    } cleave ;

TUPLE: mtab-entry file-system-name mount-point type options
frequency pass-number ;

! octal escape sequences, e.g. "/media/erg/4TB\\040E"
: decode-mount-point ( string -- string' )
    dup "\\" split
    dup length 1 > [
        nip 1 cut
        [ 3 cut [ oct> 1string ] dip append ] map append concat
    ] [
        drop
    ] if ;

: mtab-csv>mtab-entry ( csv -- mtab-entry )
    [ mtab-entry new ] dip
    {
        [ first >>file-system-name ]
        [ second decode-mount-point >>mount-point ]
        [ third >>type ]
        [ fourth string>csv first >>options ]
        [ 4 swap ?nth [ 0 ] unless* >>frequency ]
        [ 5 swap ?nth [ 0 ] unless* >>pass-number ]
    } cleave ;

: parse-mtab ( -- array )
    CHAR: \s [ "/etc/mtab" utf8 file>csv ] with-delimiter
    [ mtab-csv>mtab-entry ] map ;

: mtab-entry>file-system-info ( mtab-entry -- file-system-info/f )
    '[
        _ [ mount-point>> file-system-info ] keep
        {
            [ file-system-name>> >>device-name ]
            [ mount-point>> >>mount-point ]
            [ type>> >>type ]
        } cleave
    ] [ { [ libc-error? ] [ errno>> EACCES = ] } 1&& ] ignore-error/f ;

M: linux file-systems
    parse-mtab [ mtab-entry>file-system-info ] map sift ;

: (find-mount-point) ( path mtab-paths -- mtab-entry )
    2dup at* [
        2nip
    ] [
        drop [ parent-directory ] dip (find-mount-point)
    ] if ;

: find-mount-point ( path -- mtab-entry )
    resolve-symlinks
    parse-mtab [ [ mount-point>> ] keep ] H{ } map>assoc (find-mount-point) ;

M: linux file-system-info ( path -- file-system-info )
    normalize-path
    [
        [ new-file-system-info ] dip
        [ file-system-statfs statfs>file-system-info ]
        [ file-system-statvfs statvfs>file-system-info ] bi
        file-system-calculations
    ] keep
    find-mount-point
    {
        [ file-system-name>> >>device-name drop ]
        [ mount-point>> >>mount-point drop ]
        [ type>> >>type ]
    } 2cleave ;
