! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings assocs
classes.struct continuations fry io.backend io.backend.unix
io.directories io.files io.files.info io.files.info.unix
io.files.types kernel libc literals math sequences system unix
unix.ffi vocabs ;
IN: io.directories.unix

CONSTANT: touch-mode flags{ O_WRONLY O_APPEND O_CREAT O_EXCL }

CONSTANT: mkdir-mode flags{ USER-ALL GROUP-ALL OTHER-ALL } ! 0o777

M: unix touch-file
    normalize-path
    dup file-exists? [ touch ] [
        touch-mode file-mode open-file close-file
    ] if ;

M: unix truncate-file
    [ normalize-path ] dip [ truncate ] unix-system-call drop ;

M: unix move-file-atomically
    [ normalize-path ] bi@ [ rename ] unix-system-call drop ;

M: unix move-file
    [ move-file-atomically ] [
        dup errno>> EXDEV = [
            drop [ copy-file ] [ drop delete-file ] 2bi
        ] [ rethrow ] if
    ] recover ;

M: unix delete-file normalize-path unlink-file ;

M: unix make-directory
    normalize-path mkdir-mode [ mkdir ] unix-system-call drop ;

M: unix delete-directory
    normalize-path [ rmdir ] unix-system-call drop ;

M: unix copy-file
    [ call-next-method ]
    [ [ file-permissions ] dip swap set-file-permissions ] 2bi ;

: with-unix-directory ( path quot -- )
    dupd '[ _ _
        [ opendir dup [ throw-errno ] unless ] dip
        dupd curry swap '[ _ closedir io-error ] finally
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
        readdir_r [ (throw-errno) ] unless-zero
    ] 2keep void* deref ; inline

: >directory-entry ( dirent* -- directory-entry )
    [ d_name>> alien>native-string ]
    [ d_type>> dirent-type>file-type ] bi
    dup +unknown+ = [ drop dup file-info type>> ] when
    <directory-entry> ; inline

M: unix (directory-entries)
    [
        dirent new
        '[ _ _ next-dirent ] [ >directory-entry ] produce nip
    ] with-unix-directory ;

os linux? [ "io.directories.unix.linux" require ] when
