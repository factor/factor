! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel system math math.bitwise strings arrays
sequences combinators combinators.short-circuit alien.c-types
vocabs.loader calendar calendar.unix io.files.info
io.files.types io.backend io.directories unix unix.stat unix.time unix.users
unix.groups ;
IN: io.files.info.unix

TUPLE: unix-file-system-info < file-system-info
block-size preferred-block-size
blocks blocks-free blocks-available
files files-free files-available
name-max flags id ;

HOOK: new-file-system-info os ( --  file-system-info )

M: unix new-file-system-info ( -- ) unix-file-system-info new ;

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

TUPLE: unix-file-info < file-info uid gid dev ino
nlink rdev blocks blocksize ;

HOOK: new-file-info os ( -- file-info )

HOOK: stat>file-info os ( stat -- file-info )

HOOK: stat>type os ( stat -- file-info )

M: unix file-info ( path -- info )
    normalize-path file-status stat>file-info ;

M: unix link-info ( path -- info )
    normalize-path link-status stat>file-info ;

M: unix new-file-info ( -- class ) unix-file-info new ;

CONSTANT: standard-unix-block-size 512

M: unix stat>file-info ( stat -- file-info )
    [ new-file-info ] dip
    {
        [ stat>type >>type ]
        [ stat-st_size >>size ]
        [ stat-st_mode >>permissions ]
        [ stat-st_ctimespec timespec>unix-time >>created ]
        [ stat-st_mtimespec timespec>unix-time >>modified ]
        [ stat-st_atimespec timespec>unix-time >>accessed ]
        [ stat-st_uid >>uid ]
        [ stat-st_gid >>gid ]
        [ stat-st_dev >>dev ]
        [ stat-st_ino >>ino ]
        [ stat-st_nlink >>nlink ]
        [ stat-st_rdev >>rdev ]
        [ stat-st_blocks >>blocks ]
        [ stat-st_blksize >>blocksize ]
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

M: unix stat>type ( stat -- type )
    stat-st_mode n>file-type ;

<PRIVATE

: stat-mode ( path -- mode )
    normalize-path file-status stat-st_mode ;

: chmod-set-bit ( path mask ? -- )
    [ dup stat-mode ] 2dip
    [ bitor ] [ unmask ] if chmod io-error ;

GENERIC# file-mode? 1 ( obj mask -- ? )

M: integer file-mode? mask? ;
M: string file-mode? [ stat-mode ] dip mask? ;
M: file-info file-mode? [ permissions>> ] dip mask? ;

PRIVATE>

CONSTANT: UID           OCT: 0004000
CONSTANT: GID           OCT: 0002000
CONSTANT: STICKY        OCT: 0001000
CONSTANT: USER-ALL      OCT: 0000700
CONSTANT: USER-READ     OCT: 0000400
CONSTANT: USER-WRITE    OCT: 0000200
CONSTANT: USER-EXECUTE  OCT: 0000100
CONSTANT: GROUP-ALL     OCT: 0000070
CONSTANT: GROUP-READ    OCT: 0000040
CONSTANT: GROUP-WRITE   OCT: 0000020
CONSTANT: GROUP-EXECUTE OCT: 0000010
CONSTANT: OTHER-ALL     OCT: 0000007
CONSTANT: OTHER-READ    OCT: 0000004
CONSTANT: OTHER-WRITE   OCT: 0000002
CONSTANT: OTHER-EXECUTE OCT: 0000001

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
    [ normalize-path ] dip chmod io-error ;

: file-permissions ( path -- n )
    normalize-path file-info permissions>> ;

M: unix copy-file-and-info ( from to -- )
    [ copy-file ] [ swap file-permissions set-file-permissions ] 2bi ;

<PRIVATE

: make-timeval-array ( array -- byte-array )
    [ [ "timeval" <c-object> ] unless* ] map concat ;

: timestamp>timeval ( timestamp -- timeval )
    unix-1970 time- duration>microseconds make-timeval ;

: timestamps>byte-array ( timestamps -- byte-array )
    [ dup [ timestamp>timeval ] when ] map make-timeval-array ;

PRIVATE>

: set-file-times ( path timestamps -- )
    #! set access, write
    [ normalize-path ] dip
    timestamps>byte-array utimes io-error ;

: set-file-access-time ( path timestamp -- )
    f 2array set-file-times ;

: set-file-modified-time ( path timestamp -- )
    f swap 2array set-file-times ;

: set-file-ids ( path uid gid -- )
    [ normalize-path ] 2dip
    [ [ -1 ] unless* ] bi@ chown io-error ;

GENERIC: set-file-user ( path string/id -- )

GENERIC: set-file-group ( path string/id -- )

M: integer set-file-user ( path uid -- )
    f set-file-ids ;

M: string set-file-user ( path string -- )
    user-id f set-file-ids ;

M: integer set-file-group ( path gid -- )
    f swap set-file-ids ;

M: string set-file-group ( path string -- )
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
