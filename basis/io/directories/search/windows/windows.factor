! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays fry io.pathnames kernel sequences windows.shell32
io.directories.search ;
IN: io.directories.search.windows

: program-files-directories ( -- array )
    program-files program-files-x86 2array harvest ; inline

: find-in-program-files ( base-directory quot -- path )
    t swap [
        [ program-files-directories ] dip '[ _ append-path ] map
    ] 2dip find-in-directories ; inline
