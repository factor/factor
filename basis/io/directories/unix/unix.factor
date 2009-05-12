! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings combinators
continuations destructors fry io io.backend io.backend.unix
io.directories io.encodings.binary io.encodings.utf8 io.files
io.pathnames io.files.types kernel math.bitwise sequences system
unix unix.stat vocabs.loader ;
IN: io.directories.unix

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

M: unix copy-file ( from to -- )
    [ normalize-path ] bi@ call-next-method ;

: with-unix-directory ( path quot -- )
    [ opendir dup [ (io-error) ] unless ] dip
    dupd curry swap '[ _ closedir io-error ] [ ] cleanup ; inline

HOOK: find-next-file os ( DIR* -- byte-array )

M: unix find-next-file ( DIR* -- byte-array )
    "dirent" <c-object>
    f <void*>
    [ readdir_r 0 = [ (io-error) ] unless ] 2keep
    *void* [ drop f ] unless ;

: dirent-type>file-type ( ch -- type )
    {
        { DT_BLK  [ +block-device+ ] }
        { DT_CHR  [ +character-device+ ] }
        { DT_DIR  [ +directory+ ] }
        { DT_LNK  [ +symbolic-link+ ] }
        { DT_SOCK [ +socket+ ] }
        { DT_FIFO [ +fifo+ ] }
        { DT_REG  [ +regular-file+ ] }
        { DT_WHT  [ +whiteout+ ] }
        [ drop +unknown+ ]
    } case ;

M: unix >directory-entry ( byte-array -- directory-entry )
    {
        [ dirent-d_name utf8 alien>string ]
        [ dirent-d_type dirent-type>file-type ]
    } cleave directory-entry boa ;

M: unix (directory-entries) ( path -- seq )
    [
        '[ _ find-next-file dup ]
        [ >directory-entry ]
        produce nip
    ] with-unix-directory ;

os linux? [ "io.directories.unix.linux" require ] when
