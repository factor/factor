! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.pathnames io.directories ;
IN: io.files.temp

: temp-directory ( -- path )
    "temp" resource-path dup make-directories ;

: temp-file ( name -- path )
    temp-directory prepend-path ;