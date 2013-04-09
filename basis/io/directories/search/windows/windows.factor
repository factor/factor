! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.smart environment fry
io.directories.search io.pathnames kernel sequences
sets windows.shell32 ;
IN: io.directories.search.windows

: program-files-directories ( -- array )
    [
        program-files
        program-files-x86
        "ProgramW6432" os-env
    ] output>array harvest members ; inline

: find-in-program-files ( base-directory quot -- path )
    t swap [
        [ program-files-directories ] dip '[ _ append-path ] map
    ] 2dip find-in-directories ; inline
