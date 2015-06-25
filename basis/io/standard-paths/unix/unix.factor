! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: environment fry io io.encodings.utf8 io.files io.launcher
io.pathnames io.standard-paths kernel sequences splitting system ;
IN: io.standard-paths.unix

M: unix find-in-path*
    [ "PATH" os-env ":" split ] dip
    '[ _ append-path exists? ] find nip ;

: standard-login-paths ( -- strings )
    { "bash" "-l" "-c" "echo $PATH" }
    utf8 <process-reader> stream-contents ":" split ;

M: unix find-in-standard-login-path*
    [ standard-login-paths ] dip '[ _ append-path exists? ] find nip ;
