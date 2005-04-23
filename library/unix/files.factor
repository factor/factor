! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: files
! We want the system call stat to shadow the word stat we define
USING: alien io-internals kernel math namespaces unix-internals ;

: cd ( dir -- )
    "void" "libc" "chdir" [ "char*" ] alien-invoke ;

: stat ( path -- [ dir? mode size mtime ] )
    <stat> tuck stat 0 < [
        drop f
    ] [
        [
            dup stat-mode dup S_ISDIR ,
            S_IFMT bitnot bitand ,
            dup stat-size ,
            stat-mtime ,
        ] make-list
    ] ifte ;

: (directory) ( path -- list )
    opendir [
        [
            [ dirent-name , ] [ dup readdir null>f ] while
        ] make-list swap closedir
    ] [
        [ ]
    ] ifte* ;

: cwd ( -- str )
    <string-box> dup 255 getcwd io-error string-box-value ;

IN: streams

: <file-reader> ( path -- stream ) open-read <reader> ;

: <file-writer> ( path -- stream ) open-write <writer> ;
