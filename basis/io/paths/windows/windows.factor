! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations fry io.files io.paths
kernel windows.shell32 sequences ;
IN: io.paths.windows

: program-files-directories ( -- array )
    program-files program-files-x86 2array ; inline

: find-in-program-files ( base-directory bfs? quot -- path )
    [
        [ program-files-directories ] dip '[ _ append-path ] map
    ] 2dip find-in-directories ; inline
