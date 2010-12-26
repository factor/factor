! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
combinators continuations destructors fry io io.backend
io.backend.unix io.directories io.encodings.binary
io.encodings.utf8 io.files io.pathnames io.files.types kernel
math.bitwise sequences system unix unix.stat vocabs.loader
classes.struct unix.ffi literals ;
IN: io.directories.unix

CONSTANT: touch-mode flags{ O_WRONLY O_APPEND O_CREAT O_EXCL }

M: unix touch-file ( path -- )
    normalize-path
    dup exists? [ touch ] [
        touch-mode file-mode open-file close-file
    ] if ;

M: unix move-file ( from to -- )
    [ normalize-path ] bi@ [ rename ] unix-system-call drop ;

M: unix delete-file ( path -- ) normalize-path unlink-file ;

M: unix make-directory ( path -- )
    normalize-path OCT: 777 [ mkdir ] unix-system-call drop ;

M: unix delete-directory ( path -- )
    normalize-path [ rmdir ] unix-system-call drop ;

M: unix copy-file ( from to -- )
    [ normalize-path ] bi@ call-next-method ;

: with-unix-directory ( path quot -- )
    [ opendir dup [ (io-error) ] unless ] dip
    dupd curry swap '[ _ closedir io-error ] [ ] cleanup ; inline

HOOK: find-next-file os ( DIR* -- byte-array )

M: unix find-next-file ( DIR* -- byte-array )
    dirent <struct>
    f void* <ref>
    [ readdir_r 0 = [ (io-error) ] unless ] 2keep
    void* deref [ drop f ] unless ;

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
        [ d_name>> underlying>> utf8 alien>string ]
        [ d_type>> dirent-type>file-type ]
    } cleave directory-entry boa ;

M: unix (directory-entries) ( path -- seq )
    [
        '[ _ find-next-file dup ]
        [ >directory-entry ]
        produce nip
    ] with-unix-directory ;

os linux? [ "io.directories.unix.linux" require ] when
