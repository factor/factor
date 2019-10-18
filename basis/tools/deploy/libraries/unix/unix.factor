! Copyright (C) 2010 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.pathnames io.pathnames.private kernel
sequences system tools.deploy.libraries ;
IN: tools.deploy.libraries.unix

! stupid hack. better ways to find the library name would be open the library,
! note a symbol address found in the library, then call dladdr (or use
: ?exists ( path -- path/f )
    dup exists? [ drop f ] unless ; inline

M: unix find-library-file
    dup absolute-path? [ ?exists ] [
        { "/lib" "/usr/lib" "/usr/local/lib" "/opt/local/lib" "resource:" }
        [ prepend-path ?exists ] with map-find drop
    ] if ;
