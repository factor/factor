! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii environment io io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.launcher
io.pathnames io.standard-paths kernel math sequences splitting
system unix.users ;
IN: io.standard-paths.unix

M: unix application-directories "PATH" os-env ":" split ;

M: unix find-in-path*
    [ application-directories ] dip
    '[ _ append-path file-exists? ] find nip ;

! iterm2 spews some terminal info on every bash command.
: parse-login-paths ( seq -- strings )
    dup [ 7 = ] find-last drop [ 1 + tail-slice ] when*
    utf8 decode [ blank? ] trim ":" split ;

: standard-login-paths ( -- strings )
    { "-l" "-c" "echo \"$PATH\"" }
    effective-user-id user-passwd shell>> prefix
    binary <process-reader> stream-contents parse-login-paths ;

M: unix find-in-standard-login-path*
    [ standard-login-paths ] dip '[ _ append-path file-exists? ] find nip ;
