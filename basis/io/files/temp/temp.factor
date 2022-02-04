! Copyright (C) 2012 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators init io.directories io.pathnames kernel
namespaces system vocabs vocabs.platforms ;
IN: io.files.temp

HOOK: default-temp-directory os ( -- path )

SYMBOL: current-temp-directory

: temp-directory ( -- path )
    current-temp-directory get ;

: temp-file ( name -- path )
    temp-directory prepend-path ;

: with-temp-directory ( quot -- )
    [ temp-directory ] dip with-directory ; inline

HOOK: default-cache-directory os ( -- path )

SYMBOL: current-cache-directory

: cache-directory ( -- path )
    current-cache-directory get ;

: cache-file ( name -- path )
    cache-directory prepend-path ;

: with-cache-directory ( quot -- )
    [ cache-directory ] dip with-directory ; inline

USE-MACOSX: io.files.temp.macosx
USE-UNIX: io.files.temp.unix
USE-WINDOWS: io.files.temp.windows

STARTUP-HOOK: [
    default-temp-directory dup make-directories
    current-temp-directory set-global

    default-cache-directory dup make-directories
    current-cache-directory set-global
]
