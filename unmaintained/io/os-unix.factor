! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays calendar errors io io-internals kernel
math nonblocking-io sequences unix-internals unix-io ;
IN: libs-io

: O_APPEND  HEX: 100 ; inline
: O_EXCL    HEX: 800 ; inline
: SEEK_SET 0 ; inline
: SEEK_CUR 1 ; inline
: SEEK_END 2 ; inline
: EEXIST 17 ; inline

: mode>symbol ( mode -- ch )
    S_IFMT bitand
    {
        { [ dup S_IFDIR = ] [ drop "/" ] }
        { [ dup S_IFIFO = ] [ drop "|" ] }
        { [ dup S_IXUSR = ] [ drop "*" ] }
        { [ dup S_IFLNK = ] [ drop "@" ] }
        { [ dup S_IFWHT = ] [ drop "%" ] }
        { [ dup S_IFSOCK = ] [ drop "=" ] }
        { [ t ] [ drop "" ] }
    } cond ;
