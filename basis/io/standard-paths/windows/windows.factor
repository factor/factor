! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: environment fry io.directories.search.windows io.files
io.pathnames io.standard-paths kernel sequences splitting
system unicode.case ;
IN: io.standard-paths.windows

M: windows find-in-applications
    '[ [ >lower _ tail? ] find-in-program-files ] map-find drop ;

M: windows find-in-path*
    [ "PATH" os-env ";" split ] dip
    '[ _ append-path exists? ] find nip ;
