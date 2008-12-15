! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.bitwise io.backend kernel io.files unix
io.backend.unix io.encodings.binary io.directories io destructors
accessors io.files.info alien.c-types io.encodings.utf8 fry
sequences system continuations alien.strings ;
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

: with-unix-directory ( path quot -- )
    [ opendir dup [ (io-error) ] unless ] dip
    dupd curry swap '[ _ closedir io-error ] [ ] cleanup ; inline

: find-next-file ( DIR* -- byte-array )
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
    [ dirent-d_name utf8 alien>string ]
    [ dirent-d_type dirent-type>file-type ] bi directory-entry boa ;

M: unix (directory-entries) ( path -- seq )
    [
        '[ _ find-next-file dup ]
        [ >directory-entry ]
        [ drop ] produce
    ] with-unix-directory ;
