! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
assocs combinators continuations destructors fry io io.backend
io.directories io.encodings.binary io.files.info.unix
io.encodings.utf8 io.files io.pathnames io.files.types kernel
math math.bitwise sequences system unix unix.stat vocabs.loader
classes.struct unix.ffi literals libc vocabs io.files.info ;
IN: io.directories.unix

CONSTANT: file-mode 0o0666

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
    normalize-path 0o777 [ mkdir ] unix-system-call drop ;

M: unix delete-directory ( path -- )
    normalize-path [ rmdir ] unix-system-call drop ;

M: unix copy-file ( from to -- )
    [ normalize-path ] bi@
    [ call-next-method ]
    [ [ file-permissions ] dip swap set-file-permissions ] 2bi ;

: with-unix-directory ( path quot -- )
    dupd '[ _ _
        [ opendir dup [ (io-error) ] unless ] dip
        dupd curry swap '[ _ closedir io-error ] [ ] cleanup
    ] with-directory ; inline

: dirent-type>file-type ( type -- file-type )
    H{
        { $ DT_BLK  +block-device+ }
        { $ DT_CHR  +character-device+ }
        { $ DT_DIR  +directory+ }
        { $ DT_LNK  +symbolic-link+ }
        { $ DT_SOCK +socket+ }
        { $ DT_FIFO +fifo+ }
        { $ DT_REG  +regular-file+ }
        { $ DT_WHT  +whiteout+ }
    } at* [ drop +unknown+ ] unless ;

! An easy way to return +unknown+ is to mount a .iso on OSX and
! call directory-entries on the mount point.

: next-dirent ( DIR* dirent* -- dirent* ? )
    f void* <ref> [
        readdir_r [ dup strerror libc-error ] unless-zero
    ] 2keep void* deref ; inline

: >directory-entry ( dirent* -- directory-entry )
    [ d_name>> utf8 alien>string ]
    [ d_type>> dirent-type>file-type ] bi
    dup +unknown+ = [ drop dup file-info type>> ] when
    <directory-entry> ; inline

M: unix (directory-entries) ( path -- seq )
    [
        dirent <struct>
        '[ _ _ next-dirent ] [ >directory-entry ] produce nip
    ] with-unix-directory ;

os linux? [ "io.directories.unix.linux" require ] when
