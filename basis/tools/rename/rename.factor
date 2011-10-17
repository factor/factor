! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit io.directories.search io.files
io.files.info io.pathnames kernel sequences ;
IN: tools.rename

ERROR: directory-contains-files-error path ;

: directory-contains-files? ( path -- ? )
    qualified-directory-files [ link-info directory? ] all? not ;

: check-new-vocab-path ( old new -- old new )
    2dup [ vocab-path parent-directory ] dip append-path
    { [ exists? ] [ directory-contains-files? ] } 1&&
    [ directory-contains-files-error ] unless ;

: rename-vocab ( old new -- )
    check-new-vocab-path 2drop ;
