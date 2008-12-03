! Copyright (C) 2005, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.ports io.unix.backend io.files io
unix unix.stat unix.time kernel math continuations
math.bitwise byte-arrays alien combinators calendar
io.encodings.binary accessors sequences strings system
io.files.private destructors vocabs.loader calendar.unix
unix.stat alien.c-types arrays unix.users unix.groups
environment fry io.encodings.utf8 alien.strings
combinators.short-circuit ;
IN: io.unix.files

M: unix cwd ( -- path )
    MAXPATHLEN [ <byte-array> ] keep getcwd
    [ (io-error) ] unless* ;

M: unix cd ( path -- ) [ chdir ] unix-system-call drop ;

: read-flags O_RDONLY ; inline

: open-read ( path -- fd ) O_RDONLY file-mode open-file ;

M: unix (file-reader) ( path -- stream )
    open-read <fd> init-fd <input-port> ;

: write-flags { O_WRONLY O_CREAT O_TRUNC } flags ; inline

: open-write ( path -- fd )
    write-flags file-mode open-file ;

M: unix (file-writer) ( path -- stream )
    open-write <fd> init-fd <output-port> ;

: append-flags { O_WRONLY O_APPEND O_CREAT } flags ; inline

: open-append ( path -- fd )
    [
        append-flags file-mode open-file |dispose
        dup 0 SEEK_END lseek io-error
    ] with-destructors ;

M: unix (file-appender) ( path -- stream )
    open-append <fd> init-fd <output-port> ;

: touch-mode ( -- n )
    { O_WRONLY O_APPEND O_CREAT O_EXCL } flags ; foldable

M: unix touch-file ( path -- )
    normalize-path
    dup exists? [ touch ] [
        touch-mode file-mode open-file close-file
    ] if ;

M: unix move-file ( from to -- )
    [ normalize-path ] bi@ rename io-error ;

M: unix delete-file ( path -- ) normalize-path unlink-file ;

M: unix make-directory ( path -- )
    normalize-path OCT: 777 mkdir io-error ;

M: unix delete-directory ( path -- )
    normalize-path rmdir io-error ;

: (copy-file) ( from to -- )
    dup parent-directory make-directories
    binary <file-writer> [
        swap binary <file-reader> [
            swap stream-copy
        ] with-disposal
    ] with-disposal ;

M: unix copy-file ( from to -- )
    [ normalize-path ] bi@
    [ (copy-file) ]
    [ swap file-info permissions>> chmod io-error ]
    2bi ;

TUPLE: unix-file-system-info < file-system-info
block-size preferred-block-size
blocks blocks-free blocks-available
files files-free files-available
name-max flags id id0 id1 ;

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
    {
        [ dup [ blocks-available>> ] [ block-size>> ] bi * >>available-space drop ]
        [ dup [ blocks-free>> ] [ block-size>> ] bi * >>free-space drop ]
        [ dup [ blocks>> ] [ block-size>> ] bi * >>total-space drop ]
        [ dup [ total-space>> ] [ free-space>> ] bi - >>used-space drop ]
        [ dup id>> 2 c-uint-array> first2 [ >>id0 ] [ >>id1 ] bi* drop ]
        [ f >>id drop ]
        [ ]
    } cleave ;

M: unix file-system-info
    normalize-path
    [ new-file-system-info ] dip
    [ file-system-statfs statfs>file-system-info ]
    [ file-system-statvfs statvfs>file-system-info ] bi
    file-system-calculations ;

os {
    { linux   [ "io.unix.files.linux"   require ] }
    { macosx  [ "io.unix.files.macosx"  require ] }
    { freebsd [ "io.unix.files.freebsd" require ] }
    { netbsd  [ "io.unix.files.netbsd"  require ] }
    { openbsd [ "io.unix.files.openbsd" require ] }
} case

TUPLE: unix-file-info < file-info uid gid dev ino
nlink rdev blocks blocksize ;

HOOK: new-file-info os ( -- file-info )

HOOK: stat>file-info os ( stat -- file-info )

HOOK: stat>type os ( stat -- file-info )

M: unix file-info ( path -- info )
    normalize-path file-status stat>file-info ;

M: unix link-info ( path -- info )
    normalize-path link-status stat>file-info ;

M: unix make-link ( path1 path2 -- )
    normalize-path symlink io-error ;

M: unix read-link ( path -- path' )
   normalize-path read-symbolic-link ;

M: unix new-file-info ( -- class ) unix-file-info new ;

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

! Linux has no extra fields in its stat struct
os {
    { macosx  [ "io.unix.files.bsd" require ] }
    { netbsd  [ "io.unix.files.bsd" require ] }
    { openbsd  [ "io.unix.files.bsd" require ] }
    { freebsd  [ "io.unix.files.bsd" require ] }
    { linux [ ] }
} case

: with-unix-directory ( path quot -- )
    [ opendir dup [ (io-error) ] unless ] dip
    dupd curry swap '[ _ closedir io-error ] [ ] cleanup ; inline

: find-next-file ( DIR* -- byte-array )
    "dirent" <c-object>
    f <void*>
    [ readdir_r 0 = [ (io-error) ] unless ] 2keep
    *void* [ drop f ] unless ;

M: unix >directory-entry ( byte-array -- directory-entry )
    [ dirent-d_name utf8 alien>string ]
    [ dirent-d_type dirent-type>file-type ] bi directory-entry boa ;

M: unix (directory-entries) ( path -- seq )
    [
        '[ _ find-next-file dup ]
        [ >directory-entry ]
        [ drop ] produce
    ] with-unix-directory ;

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

: file-type>ch ( type -- string )
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

: UID           OCT: 0004000 ; inline
: GID           OCT: 0002000 ; inline
: STICKY        OCT: 0001000 ; inline
: USER-ALL      OCT: 0000700 ; inline
: USER-READ     OCT: 0000400 ; inline
: USER-WRITE    OCT: 0000200 ; inline
: USER-EXECUTE  OCT: 0000100 ; inline
: GROUP-ALL     OCT: 0000070 ; inline
: GROUP-READ    OCT: 0000040 ; inline
: GROUP-WRITE   OCT: 0000020 ; inline
: GROUP-EXECUTE OCT: 0000010 ; inline
: OTHER-ALL     OCT: 0000007 ; inline
: OTHER-READ    OCT: 0000004 ; inline
: OTHER-WRITE   OCT: 0000002 ; inline
: OTHER-EXECUTE OCT: 0000001 ; inline

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

<PRIVATE

: make-timeval-array ( array -- byte-array )
    [ length "timeval" <c-array> ] keep
    dup length [ over [ pick set-timeval-nth ] [ 2drop ] if ] 2each ;

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

: file-username ( path -- string )
    file-user-id username ;

: file-group-id ( path -- gid )
    normalize-path file-info gid>> ;

: file-group-name ( path -- string )
    file-group-id group-name ;

M: unix home "HOME" os-env ;
