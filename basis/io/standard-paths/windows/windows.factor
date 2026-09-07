! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators.smart environment fry
io.directories io.files io.pathnames io.standard-paths
io.standard-paths.private kernel sequences sets splitting system unicode
windows.shell32 ;
IN: io.standard-paths.windows

M: windows application-directories
    [
        program-files
        program-files-x86
        "ProgramW6432" os-env
        "LOCALAPPDATA" os-env "Programs" append-path
    ] output>array harvest members ;

: find-in-program-files ( base-directory quot -- path )
    [ application-directories ]
    [ '[ _ append-path ] map ]
    [ find-file-in-directories ] tri* ; inline

M: windows find-in-applications
    >lower
    '[ [ >lower _ tail? ] find-in-program-files ] map-find drop ;

M:: windows find-in-path* ( command -- path/f )
    "PATHEXT" os-env executable-extensions :> extensions
    command extensions windows-command-names
    "PATH" os-env [ ";" split ] [ { } ] if*
    [ extensions windows-executable-file? ] find-path-entry ;
