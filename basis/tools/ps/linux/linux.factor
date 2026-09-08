! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations destructors io.directories kernel
math.parser sequences splitting system tools.ps unix.linux.proc ;
IN: tools.ps.linux

! If cmdline is empty, read the filename from /proc/pid/stat
: ps-cmdline ( path -- string )
    dup parse-proc-pid-cmdline [
        parse-proc-pid-stat filename>>
        1 head* 1 tail
        "[" "]" surround
    ] [
        nip "\0" split harvest join-words
    ] if-empty ;

: safe-ps-cmdline ( path -- string/f )
    [ <proc-pid-directory> [ ps-cmdline ] with-disposal ]
    [ 2drop f ] recover ;

M: linux ps
    "/proc" [
        "." directory-files [ string>number ] filter
        [ dup safe-ps-cmdline 2array ] map sift-values
    ] with-directory ;
