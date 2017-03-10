! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.smart environment fry
io.directories.search io.files io.pathnames io.standard-paths
kernel sequences sets splitting system unicode windows.shell32 ;
IN: io.standard-paths.windows

: program-files-directories ( -- array )
    [
        program-files
        program-files-x86
        "ProgramW6432" os-env
    ] output>array harvest members ; inline

: find-in-program-files ( base-directory quot -- path )
    [ program-files-directories ]
    [ '[ _ append-path ] map ]
    [ find-file-in-directories ] tri* ; inline

M: windows find-in-applications
    >lower
    '[ [ >lower _ tail? ] find-in-program-files ] map-find drop ;

M: windows find-in-path*
    [ "PATH" os-env ";" split ] dip
    '[ _ append-path exists? ] find nip ;
