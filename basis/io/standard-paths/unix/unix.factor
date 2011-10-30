! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: environment fry io.files io.pathnames io.standard-paths
kernel sequences splitting system ;
IN: io.standard-paths.unix

M: unix find-path*
    [ "PATH" os-env ":" split ] dip
    '[ _ append-path exists? ] find nip ;

