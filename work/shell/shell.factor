! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.directories sequences folder ;
IN: shell

USE: folder
: ls-write-columns ( entry -- )
    name>> write " " write
    ;

: ls ( path -- )
    directory-entries [ ls-write-columns ] each
    ;
