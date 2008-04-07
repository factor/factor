! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.nonblocking io.unix.backend io.files io
unix unix.stat unix.time kernel math continuations
math.bitfields byte-arrays alien combinators calendar
io.encodings.binary accessors sequences strings system
io.files.private ;

IN: io.unix.files

M: unix cwd ( -- path )
    MAXPATHLEN [ <byte-array> ] [ ] bi getcwd
    [ (io-error) ] unless* ;

M: unix cd ( path -- )
    chdir io-error ;

: read-flags O_RDONLY ; inline

: open-read ( path -- fd )
    O_RDONLY file-mode open dup io-error ;

M: unix (file-reader) ( path -- stream )
    open-read <reader> ;

: write-flags { O_WRONLY O_CREAT O_TRUNC } flags ; inline

: open-write ( path -- fd )
    write-flags file-mode open dup io-error ;

M: unix (file-writer) ( path -- stream )
    open-write <writer> ;

: append-flags { O_WRONLY O_APPEND O_CREAT } flags ; inline

: open-append ( path -- fd )
    append-flags file-mode open dup io-error
    [ dup 0 SEEK_END lseek io-error ] [ ] [ close ] cleanup ;

M: unix (file-appender) ( path -- stream )
    open-append <writer> ;

: touch-mode ( -- n )
    { O_WRONLY O_APPEND O_CREAT O_EXCL } flags ; foldable

M: unix touch-file ( path -- )
    normalize-path
    touch-mode file-mode open
    dup 0 < [ err_no EEXIST = [ err_no io-error ] unless ] when
    close ;

M: unix move-file ( from to -- )
    [ normalize-path ] bi@ rename io-error ;

M: unix delete-file ( path -- )
    normalize-path unlink io-error ;

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
    [ swap file-info file-info-permissions chmod io-error ]
    2bi ;

: stat>type ( stat -- type )
    stat-st_mode {
        { [ dup S_ISREG  ] [ +regular-file+     ] }
        { [ dup S_ISDIR  ] [ +directory+        ] }
        { [ dup S_ISCHR  ] [ +character-device+ ] }
        { [ dup S_ISBLK  ] [ +block-device+     ] }
        { [ dup S_ISFIFO ] [ +fifo+             ] }
        { [ dup S_ISLNK  ] [ +symbolic-link+    ] }
        { [ dup S_ISSOCK ] [ +socket+           ] }
        { [ t            ] [ +unknown+          ] }
    } cond nip ;

: stat>file-info ( stat -- info )
    {
        [ stat>type ]
        [ stat-st_size ]
        [ stat-st_mode ]
        [ stat-st_mtim timespec-sec seconds unix-1970 time+ ]
    } cleave
    \ file-info construct-boa ;

M: unix file-info ( path -- info )
    normalize-path stat* stat>file-info ;

M: unix link-info ( path -- info )
    normalize-path lstat* stat>file-info ;

M: unix make-link ( path1 path2 -- )
    normalize-path symlink io-error ;

M: unix read-link ( path -- path' )
    normalize-path
    PATH_MAX [ <byte-array> tuck ] [ ] bi readlink
    dup io-error head-slice >string ;
