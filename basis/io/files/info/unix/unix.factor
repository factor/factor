! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays calendar calendar.unix
classes.struct combinators combinators.short-circuit io.backend
io.files.info io.files.types kernel libc math math.bitwise
sequences specialized-arrays strings system unix unix.ffi
unix.groups unix.stat unix.time unix.users vocabs ;
IN: io.files.info.unix
SPECIALIZED-ARRAY: timeval

TUPLE: unix-file-system-info < file-system-info-tuple
block-size preferred-block-size
blocks blocks-free blocks-available
files files-free files-available
name-max flags id ;

HOOK: new-file-system-info os ( -- file-system-info )

M: unix new-file-system-info unix-file-system-info new ;

HOOK: file-system-statfs os ( path -- statfs )

M: unix file-system-statfs drop f ;

HOOK: file-system-statvfs os ( path -- statvfs )

M: unix file-system-statvfs drop f ;

HOOK: statfs>file-system-info os ( file-system-info statfs -- file-system-info' )

M: unix statfs>file-system-info drop ;

HOOK: statvfs>file-system-info os ( file-system-info statvfs -- file-system-info' )

M: unix statvfs>file-system-info drop ;

: file-system-calculations ( file-system-info -- file-system-info' )
    dup [ blocks-available>> ] [ block-size>> ] bi * >>available-space
    dup [ blocks-free>> ] [ block-size>> ] bi * >>free-space
    dup [ blocks>> ] [ block-size>> ] bi * >>total-space
    dup [ total-space>> ] [ free-space>> ] bi - >>used-space ;

M: unix file-system-info
    normalize-path
    [ new-file-system-info ] dip
    [ file-system-statfs statfs>file-system-info ]
    [ file-system-statvfs statvfs>file-system-info ] bi
    file-system-calculations ;

TUPLE: unix-file-info < file-info-tuple uid gid dev ino
nlink rdev blocks blocksize ;

HOOK: new-file-info os ( -- file-info )

HOOK: stat>file-info os ( stat -- file-info )

HOOK: stat>type os ( stat -- file-info )

M: unix file-info
    normalize-path file-status stat>file-info ;

M: unix link-info
    normalize-path link-status stat>file-info ;

M: unix new-file-info unix-file-info new ;

CONSTANT: standard-unix-block-size 512

M: unix stat>file-info
    [ new-file-info ] dip
    {
        [ stat>type >>type ]
        [ st_size>> >>size ]
        [ st_mode>> >>permissions ]
        [ st_ctimespec>> timespec>unix-time >>created ]
        [ st_mtimespec>> timespec>unix-time >>modified ]
        [ st_atimespec>> timespec>unix-time >>accessed ]
        [ st_uid>> >>uid ]
        [ st_gid>> >>gid ]
        [ st_dev>> >>dev ]
        [ st_ino>> >>ino ]
        [ st_nlink>> >>nlink ]
        [ st_rdev>> >>rdev ]
        [ st_blocks>> >>blocks ]
        [ st_blksize>> >>blocksize ]
        [ drop dup blocks>> standard-unix-block-size * >>size-on-disk ]
    } cleave ;

: n>file-type ( n -- type )
    S_IFMT bitand {
        { S_IFREG [ +regular-file+ ] }
        { S_IFDIR [ +directory+ ] }
        { S_IFCHR [ +character-device+ ] }
        { S_IFBLK [ +block-device+ ] }
        { S_IFIFO [ +fifo+ ] }
        { S_IFLNK [ +symbolic-link+ ] }
        { S_IFSOCK [ +socket+ ] }
        [ drop +unknown+ ]
    } case ;

M: unix stat>type
    st_mode>> n>file-type ;

<PRIVATE

: stat-mode ( path -- mode )
    normalize-path file-status st_mode>> ;

: chmod-set-bit ( path mask ? -- )
    [ dup stat-mode ] 2dip
    [ bitor ] [ unmask ] if [ chmod ] unix-system-call drop ;

GENERIC#: file-mode? 1 ( obj mask -- ? )

M: integer file-mode? mask? ;
M: string file-mode? [ stat-mode ] dip mask? ;
M: file-info-tuple file-mode? [ permissions>> ] dip mask? ;

PRIVATE>

CONSTANT: UID           0o0004000
CONSTANT: GID           0o0002000
CONSTANT: STICKY        0o0001000
CONSTANT: USER-ALL      0o0000700
CONSTANT: USER-READ     0o0000400
CONSTANT: USER-WRITE    0o0000200
CONSTANT: USER-EXECUTE  0o0000100
CONSTANT: GROUP-ALL     0o0000070
CONSTANT: GROUP-READ    0o0000040
CONSTANT: GROUP-WRITE   0o0000020
CONSTANT: GROUP-EXECUTE 0o0000010
CONSTANT: OTHER-ALL     0o0000007
CONSTANT: OTHER-READ    0o0000004
CONSTANT: OTHER-WRITE   0o0000002
CONSTANT: OTHER-EXECUTE 0o0000001
CONSTANT: ALL-READ      0o0000444
CONSTANT: ALL-WRITE     0o0000222
CONSTANT: ALL-EXECUTE   0o0000111

: uid? ( obj -- ? ) UID file-mode? ;
: gid? ( obj -- ? ) GID file-mode? ;
: sticky? ( obj -- ? ) STICKY file-mode? ;
: user-read? ( obj -- ? ) USER-READ file-mode? ;
: user-write? ( obj -- ? ) USER-WRITE file-mode? ;
: user-execute? ( obj -- ? ) USER-EXECUTE file-mode? ;
: group-read? ( obj -- ? ) GROUP-READ file-mode? ;
: group-write? ( obj -- ? ) GROUP-WRITE file-mode? ;
: group-execute? ( obj -- ? ) GROUP-EXECUTE file-mode? ;
: other-read? ( obj -- ? ) OTHER-READ file-mode? ;
: other-write? ( obj -- ? ) OTHER-WRITE file-mode? ;
: other-execute? ( obj -- ? ) OTHER-EXECUTE file-mode? ;

: any-read? ( obj -- ? )
    { [ user-read? ] [ group-read? ] [ other-read? ] } 1|| ;

: any-write? ( obj -- ? )
    { [ user-write? ] [ group-write? ] [ other-write? ] } 1|| ;

: any-execute? ( obj -- ? )
    { [ user-execute? ] [ group-execute? ] [ other-execute? ] } 1|| ;

: set-uid ( path ? -- ) UID swap chmod-set-bit ;
: set-gid ( path ? -- ) GID swap chmod-set-bit ;
: set-sticky ( path ? -- ) STICKY swap chmod-set-bit ;
: set-user-read ( path ? -- ) USER-READ swap chmod-set-bit ;
: set-user-write ( path ? -- ) USER-WRITE swap chmod-set-bit ;
: set-user-execute ( path ? -- ) USER-EXECUTE swap chmod-set-bit ;
: set-group-read ( path ? -- ) GROUP-READ swap chmod-set-bit ;
: set-group-write ( path ? -- ) GROUP-WRITE swap chmod-set-bit ;
: set-group-execute ( path ? -- ) GROUP-EXECUTE swap chmod-set-bit ;
: set-other-read ( path ? -- ) OTHER-READ swap chmod-set-bit ;
: set-other-write ( path ? -- ) OTHER-WRITE swap chmod-set-bit ;
: set-other-execute ( path ? -- ) OTHER-EXECUTE swap chmod-set-bit ;

: set-file-permissions ( path n -- )
    [ normalize-path ] dip [ chmod ] unix-system-call drop ;

: file-permissions ( path -- n )
    normalize-path file-info permissions>> ;

: add-file-permissions ( path n -- )
    over file-permissions bitor set-file-permissions ;

: remove-file-permissions ( path n -- )
    over file-permissions [ bitnot ] dip bitand set-file-permissions ;

<PRIVATE

: timestamp>timeval ( timestamp -- timeval )
    unix-1970 time- duration>microseconds make-timeval ;

: timestamps>byte-array ( timestamps -- byte-array )
    [ [ timestamp>timeval ] [ \ timeval new ] if* ] map
    timeval >c-array ;

PRIVATE>

: set-file-times ( path timestamps -- )
    ! set access, write
    [ normalize-path ] dip
    timestamps>byte-array [ utimes ] unix-system-call drop ;

: set-file-access-time ( path timestamp -- )
    over file-info modified>> 2array set-file-times ;

: set-file-modified-time ( path timestamp -- )
    over file-info accessed>> swap 2array set-file-times ;

: set-file-ids ( path uid gid -- )
    [ normalize-path ] 2dip [ -1 or ] bi@
    [ chown ] unix-system-call drop ;

GENERIC: set-file-user ( path string/id -- )

GENERIC: set-file-group ( path string/id -- )

M: integer set-file-user
    f set-file-ids ;

M: string set-file-user
    user-id f set-file-ids ;

M: integer set-file-group
    f swap set-file-ids ;

M: string set-file-group
    group-id
    f swap set-file-ids ;

: file-user-id ( path -- uid )
    normalize-path file-info uid>> ;

: file-user-name ( path -- string )
    file-user-id user-name ;

: file-group-id ( path -- gid )
    normalize-path file-info gid>> ;

: file-group-name ( path -- string )
    file-group-id group-name ;

: ch>file-type ( ch -- type )
    {
        { CHAR: b [ +block-device+ ] }
        { CHAR: c [ +character-device+ ] }
        { CHAR: d [ +directory+ ] }
        { CHAR: l [ +symbolic-link+ ] }
        { CHAR: s [ +socket+ ] }
        { CHAR: p [ +fifo+ ] }
        { CHAR: - [ +regular-file+ ] }
        [ drop +unknown+ ]
    } case ;

: file-type>ch ( type -- ch )
    {
        { +block-device+ [ CHAR: b ] }
        { +character-device+ [ CHAR: c ] }
        { +directory+ [ CHAR: d ] }
        { +symbolic-link+ [ CHAR: l ] }
        { +socket+ [ CHAR: s ] }
        { +fifo+ [ CHAR: p ] }
        { +regular-file+ [ CHAR: - ] }
        [ drop CHAR: - ]
    } case ;

<PRIVATE

: file-type>executable ( directory-entry -- string )
    name>> any-execute? "*" "" ? ;

PRIVATE>

: file-type>trailing ( directory-entry -- string )
    dup type>>
    {
        { +directory+ [ drop "/" ] }
        { +symbolic-link+ [ drop "@" ] }
        { +fifo+ [ drop "|" ] }
        { +socket+ [ drop "=" ] }
        { +whiteout+ [ drop "%" ] }
        { +unknown+ [ file-type>executable ] }
        { +regular-file+ [ file-type>executable ] }
        [ drop file-type>executable ]
    } case ;

<PRIVATE

: access? ( path mode -- ? )
    [ normalize-path ] [ access ] bi* 0 < [
        errno EACCES = [ f ] [ throw-errno ] if
    ] [ t ] if ;

PRIVATE>

M: unix file-readable? R_OK access? ;
M: unix file-writable? W_OK access? ;
M: unix file-executable? X_OK access? ;

"io.files.info.unix." os name>> append require
