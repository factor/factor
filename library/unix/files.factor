! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: files
USING: alien io-internals kernel math namespaces ;

: cd ( dir -- )
    "void" "libc" "chdir" [ "char*" ] alien-invoke ;

: stat ( path -- [ dir? mode size mtime ] )
    <stat> tuck sys-stat 0 < [
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
    sys-opendir [
        [
            [ dirent-name , ] [ dup sys-readdir null>f ] while
        ] make-list swap sys-closedir
    ] [
        [ ]
    ] ifte* ;

: cwd ( -- str )
    <string-box> dup 255 sys-getcwd io-error string-box-value ;
